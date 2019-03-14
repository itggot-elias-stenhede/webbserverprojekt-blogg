require 'sinatra'
require 'slim'
enable :sessions
require_relative './controller.rb'

get ("/") do
    redirect("/home")
end

get ("/login") do
    slim(:login)
end

post ("/login") do
    db = SQLite3::Database.new("db/blog.db")

    if params["Username"].length > 0
        hashed_pass = db.execute("SELECT Password FROM users WHERE Username = '#{params["Username"]}'")
    else
        redirect("/login")
    end

    if hashed_pass.length == 0
        redirect("/login")
    end

    hashed_pass = hashed_pass.first.first

    if BCrypt::Password.new(hashed_pass) == params["Password"]
        session[:loggedin] = true
        session[:username] = params["Username"]
        redirect("/loggedin")
    else
        redirect("/loginfailed")
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

get ("/loginfailed") do
    slim(:loginfailed)
end

get ("/updatefailed") do
    slim(:updatefailed)
end

get("/permission") do
    slim(:permission)
end

post("/makepost") do
    makepost(session[:username], params["header"], params["text"])
    redirect("/home")
end

get("/home") do
    db = SQLite3::Database.new("db/blog.db")
    session[:blogposts] = db.execute("SELECT * FROM posts")
    slim(:home)
end

get("/profile") do
    if session[:loggedin]
        db = SQLite3::Database.new("db/blog.db")
        slim(:profile)
    else
        redirect("/permission")
    end
end

post("/profile") do
    if session[:loggedin]
        db = SQLite3::Database.new("db/blog.db")
        if params["username"].length > 0
            hashed_pass = db.execute("SELECT Password FROM users WHERE Username = '#{session[:username]}'").first.first
        else
            redirect("/profile")
        end

        if params["newpassword1"] == params["newpassword2"] && BCrypt::Password.new(hashed_pass) == params["currentpassword"]    #???
            new_hashed_pass = BCrypt::Password.create("#{params["newpassword1"]}")
            db.execute("UPDATE users SET Username = ?, Password = ? WHERE Username = '#{session[:username]}'", params["username"], new_hashed_pass)  #???
            session.destroy
            redirect("/home")
        else
            redirect("/profile")                    #fix
        end
    else
        redirect("/permission")
    end
end

get("/makepost") do
    if session[:loggedin]
        slim(:makepost)
    else
        redirect("/permission")
    end
end