#Denna runnas efter tables droppats i seed!

require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

words = File.readlines('words.txt')


words.each do |word|
    db.execute('INSERT INTO words (text) VALUES (?)', word)
end