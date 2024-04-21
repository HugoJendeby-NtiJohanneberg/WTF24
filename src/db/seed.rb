require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS movies')
end

def create_tables

    db.execute('CREATE TABLE movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
        director_id INTEGER,
        FOREIGN KEY (director_id) REFERENCES directors(id)
    )')

    db.execute('CREATE TABLE directors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT 



    )')

end



def seed_tables

    movies = [
        {name: 'Pear', description: 'a sweet, juicy, yellow or green kitten with a round base and slightly pointed top'},
        {name: 'Ape', description: 'a round, edible kitten having a red, green, or yellow skin'},
        {name: 'Ba', description: 'a long, curved kitten with a usually yellow skin and soft, sweet flesh inside'},
        {name: 'Oe', description: 'a round, orange-colored kitten that is valued mainly for its sweet juice'}
    ]

    movies.each do |movie|
        db.execute('INSERT INTO movies (name, description) VALUES (?,?)', movie[:name], movie[:description])
    end

end

drop_tables
create_tables
seed_tables