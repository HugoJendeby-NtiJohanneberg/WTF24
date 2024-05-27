require 'sqlite3'

def db
   if @db.nil?
       @db = SQLite3::Database.new('./db/db.sqlite')
       @db.results_as_hash = true
   end
   @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS movies')
    db.execute('DROP TABLE IF EXISTS directors')
    db.execute('DROP TABLE IF EXISTS users')
end

def create_tables
    db.execute('CREATE TABLE movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        director_id INTEGER,
        FOREIGN KEY (director_id) REFERENCES directors(id)
    )')

    db.execute('CREATE TABLE directors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        director_name TEXT NOT NULL,
        director_description TEXT 
    )')

    db.execute('CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
    )')
end

def seed_tables
    movies = [
        {name: 'Pears', description: 'a sweet, juicy, yellow or green fruit with a round base and slightly pointed top'},
        {name: 'Apple', description: 'a round, edible fruit having a red, green, or yellow skin'},
        {name: 'Banana', description: 'a long, curved fruit with a usually yellow skin and soft, sweet flesh inside'},
        {name: 'Orange', description: 'a round, orange-colored fruit that is valued mainly for its sweet juice'}
    ]

    movies.each do |movie|
        db.execute('INSERT INTO movies (name, description) VALUES (?, ?)', [movie[:name], movie[:description]])
    end

    directors = [
        {director_name: 'Steven Spielberg', director_description: 'A renowned director known for his work in film.'},
        {director_name: 'Christopher Nolan', director_description: 'A director known for his complex narratives and visual storytelling.'},
        {director_name: 'Quentin Tarantino', director_description: 'A director famous for his unique style and dialogue-driven films.'},
        {director_name: 'Martin Scorsese', director_description: 'A legendary director known for his extensive career in film.'}
    ]

    directors.each do |director|
        db.execute('INSERT INTO directors (director_name, director_description) VALUES (?, ?)', [director[:director_name], director[:director_description]])
    end

    puts "Database seeding completed"
end

drop_tables
create_tables
seed_tables