require 'SQLite3'
require 'sinatra'
require 'slim'
require 'bcrypt'
enable :sessions

get ("/") do
    session.destroy
    slim(:home)
end

get ("/login") do
    slim(:login)
end

post ("/login") do
    db = SQLite3::Database.new("db/user_pass.db")

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
        redirect("/login")
    end
end

get ("/home") do
    slim(:home)
end

get ("/register") do
    slim(:register)
end

post ("/register") do
    db = SQLite3::Database.new("db/user_pass.db")
    hashed_pass = BCrypt::Password.create("#{params["Password"]}")
    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_pass)
    redirect("/login")
end

get ("/loggedin") do
    if session[:loggedin]
        slim(:loggedin)
    end
end