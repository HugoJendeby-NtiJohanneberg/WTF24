class App < Sinatra::Base

    helpers do
        def h(text)
          Rack::Utils.escape_html(text)
        end
      
        def hattr(text)
          Rack::Utils.escape_path(text)
        end
    end

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
        director_name = params['director_name']
        director_desc = params['director_description']

        # Kolla om director redan finns
        director = db.execute('SELECT * FROM directors WHERE name = ?', director_name).first

        # Om director inte finns, skapa en ny
        if director.nil?
            # Insert new director into the directors table
            db.execute('INSERT INTO directors (name, description) VALUES (?, ?)', director_name, director_desc).
            # Retrieve the newly inserted director's ID
            director_id = db.last_insert_row_id
        else   
            # Om director redan finns, använd det existerande directorns ID
            director_id = director['id']
        end

        # Inserta movie in i movies table, inkluderar director_id
        query = 'INSERT INTO movies (name, description, ) VALUES (?,?) RETURNING *'
        result = db.execute(query, name, desc).first 
        redirect "/movies/#{result['id']}" 
    end

    get '/register_user' do
        erb :register_user
    end 

    post '/register_user/' do 
        cleartext_password = params['password'] 
        hashed_password = BCrypt::Password.create(cleartext_password) # Hashing the password directly without salt key
        # Save the username and hashed password to the database
        query = 'INSERT INTO users (username, password) VALUES (?,?) RETURNING *'
        db.execute(query, params['username'], hashed_password).first
        redirect "/login/" 
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
        p "wut"
        @movies_selected = db.execute('SELECT * FROM movies WHERE id=?;', movie_id.to_i).first
        erb :show
    end

end