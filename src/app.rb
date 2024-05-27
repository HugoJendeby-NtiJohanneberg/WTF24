class App < Sinatra::Base
    enable :sessions
    # Feedback: Kolla om någon är inloggad för tillgång till app.rb och new.rb formulär.
    # Fixa inlogg och uppsäkring av routes,
    # påbörja moduler

    # helpers 
    helpers do
        # h(text) används för att undvika injektionsattacker, 
        # genom att ta bort special characters i inputs
        def h(text)
            Rack::Utils.escape_html(text)
        end

        def hattr(text)
            Rack::Utils.escape_path(text)
        end

        def logged_in?
            !!session[:user_id]
        end

        def current_user
            @current_user ||= db.execute('SELECT * FROM users WHERE id = ?', session[:user_id]).first if logged_in?
        end

        def logout_button
            '<form action="/logout" method="POST" style="display:inline;">
                <button type="submit">Logout</button>
             </form>'
        end
    end

    def db
        if @db.nil?
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        @db
    end

    # Access kontroll med hjälp av before och unless.
    before '/movies/new' do
        redirect '/login' unless logged_in?
    end

    before '/movies/:id/delete' do
        redirect '/login' unless logged_in?
    end

    before '/movies/:id/update' do
        redirect '/login' unless logged_in?
    end

    before '/movies/:id/edit' do
        redirect '/login' unless logged_in?
    end


    get '/' do
        erb :index
        erb :login
    end

    get '/movies' do
        @movies = db.execute('SELECT * FROM movies')
        erb :movies
    end

    get '/movies/new' do
        erb :'new'
    end

    post '/movies/' do
        # feedback: Kolla om användare är inloggad
        name = h(params['name'])
        desc = h(params['description'])
        director_name = h(params['director_name'])
        director_description = h(params['director_description'])

        # Kolla om director redan finns
        director = db.execute('SELECT * FROM directors WHERE director_name = ?', director_name).first

        # Om director inte finns, skapa en ny
        if director.nil?
            # Inserta ny director till directors table
            db.execute('INSERT INTO directors (director_name, director_description) VALUES (?, ?)', director_name, director_description)
            # Hämta nyligen inserted director's ID
            director_id = db.last_insert_row_id
        else
            # Om director redan finns, använd det existerande directorns ID
            director_id = director['id']
        end

        # Inserta movie in i movies table, inkluderar director_id
        db.execute('INSERT INTO movies (name, description, director_id) VALUES (?, ?, ?)', name, desc, director_id)
        movie_id = db.last_insert_row_id
        redirect "/movies/#{movie_id}"
    end

    get '/register_user' do
        erb :register_user
    end

    # Register user route där användare skapar ett konto
    post '/register_user/' do
        username = h(params['username'])
        cleartext_password = params['password'] 
        hashed_password = BCrypt::Password.create(cleartext_password) # hashar password utan saltkey
        db.execute('INSERT INTO users (username, password) VALUES (?, ?)', username, hashed_password) # sparar information i databasen

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first
        session[:user_id] = user['id'] # Vid lyckad registrering används users ID i sessionen vilket loggar in dom automatiskt.

        redirect "/"
    end

    # h behövs inte för login då den inte displayar någon något redan ifyllt user input
    get '/login' do
        erb :login
    end

    post '/login' do
        username = h(params['username'])
        password = params['password'] 

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first

        if user && BCrypt::Password.new(user['password']) == password
            session[:user_id] = user['id']
            redirect '/movies'
        else
            redirect '/login'
        end
    end

    post '/logout' do
        session.clear
        redirect '/login'
    end

    get '/movies/:id/edit' do |id|
        @movies = db.execute('SELECT * FROM movies WHERE id = ?', id.to_i).first
        erb :edit
    end

    # Update
    # get hämtar länk, Post skickar information till länk
    # Post var formuläret skickar datan.
    post '/movies/:id/update' do |id|
        name = h(params['name'])
        description = h(params['description'])
        db.execute('UPDATE movies SET name = ?, description = ? WHERE id = ?', name, description, id)
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
        @movies_selected = db.execute('SELECT movies.*, directors.director_name FROM movies JOIN directors ON movies.director_id = directors.id WHERE movies.id = ?', movie_id.to_i).first
        erb :show
    end

    get '/directors' do
        @directors = db.execute('SELECT directors.*, movies.id AS movie_id, movies.name AS movie_name FROM directors LEFT JOIN movies ON directors.id = movies.director_id')
        erb :directors
    end
end

