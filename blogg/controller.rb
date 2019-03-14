require 'SQLite3'
require 'bcrypt'

def database()
    return SQLite3::Database.new("db/blog.db")
end

def makepost(params)
    p params
    db = database()
    time = Time.now.to_s[0..18]
    db.execute("INSERT INTO posts (Username, Header, Text, Time) VALUES (?, ?, ?, ?)", session[:username], params["header"], params["text"], time)
end

