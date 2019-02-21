require 'SQLite3'
require 'sinatra'
require 'slim'
require 'bcrypt'
enable :sessions

get ("/") do
    redirect("/home")
end

get ("/login") do
    slim(:login)
end

post ("/login") do
    db = SQLite3::Database.new("db/blog.db")

    hashed_pass = db.execute("SELECT Password FROM users WHERE Username = '#{params["Username"]}'")
    
    if hashed_pass.length == 0
        redirect("/login")
    end

    hashed_pass = hashed_pass[0][0]

    if BCrypt::Password.new(hashed_pass) == params["Password"]
        session[:loggedin] = true
        session[:username] = params["Username"]
        redirect("/loggedin")
    else
        redirect("/failed")
    end
end

get ("/register") do
    slim(:register)
end

post ("/register") do
    db = SQLite3::Database.new("db/blog.db")
    hashed_pass = BCrypt::Password.create("#{params["Password"]}")
    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_pass)
    redirect("/login")
end

get ("/loggedin") do
    if session[:loggedin]
        slim(:loggedin)
    else
        redirect("/permission")
    end
end

get ("/failed") do
    slim(:failed)
end

get("/permission") do
    slim(:permission)
end

post("/makepost") do
    db = SQLite3::Database.new("db/blog.db")
    db.execute("INSERT INTO posts (Username, Header, Text, Time) VALUES (?, ?, ?, ?)", session[:username], params["header"], params["text"], Time.now.to_s[0..9])
    redirect("/home")
end

get("/home") do
    db = SQLite3::Database.new("db/blog.db")
    session[:blogposts] = db.execute("SELECT * FROM posts")

    slim(:home)
end