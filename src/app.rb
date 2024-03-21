class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        erb :index
    end

    get '/movies' do
        @movies = db.execute('SELECT * FROM movies')
        erb :movies
    end

    get '/movies/new' do 
        erb :'new'
    end

    post '/movies/' do 
        name = params['name']
        desc = params['description']
        query = 'INSERT INTO movies (name, description) VALUES (?,?) RETURNING *'
        result = db.execute(query, name, desc).first 
        redirect "/movies/#{result['id']}" 
    end
    
    get '/movies/:id/edit' do |id| 
        @movies = db.execute('SELECT * FROM movies WHERE id = ?', id.to_i).first
        erb :edit
    end 

    # Update 
    #  get hämtar länk, Post skickar information till länk
    # Post var formuläret skickar datan.
    post '/movies/:id/update' do |id| 
        movie = params['content']
        db.execute('UPDATE movies SET (content = ?) WHERE id = ?', movie, id)
        redirect "/movies/#{id}" 
    end

    # Get hämtar i detta fall delete-formuläret
    get '/movies/:id/delete' do |id|
        @movie = db.execute('SELECT * FROM movies WHERE id=?;', id.to_i).first
        erb :delete
    end

    # Post är dit formuläret skickar datorn,och där kommandot för att ta bort instansen körs.
    post '/movies/:id/delete' do |id| 
        db.execute('DELETE FROM movies WHERE id = ?', id)
        redirect "/movies"
    end

    get '/movies/:id' do |movie_id|
        @movies_selected = db.execute('SELECT * FROM movies JOIN director on movies.director_id = director.director_id WHERE id=?;', movie_id.to_i).first
        erb :show
    end

    

end