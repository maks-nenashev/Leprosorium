#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
    @db.results_as_hash = true
  end

before do
	init_db  # Database Initialization
  end

configure do             #Sozdanie SQL
	db = init_db     #CREATE TABLE IF NOT EXISTS 
	@db.execute 'CREATE TABLE IF NOT EXISTS  "Posts" 
	  (
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date" DATE,
		"content" TEXT
		)'
	@db.execute 'CREATE TABLE IF NOT EXISTS  "Comments" 
	  (
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	    "created_date" DATE,
		"content" TEXT,
		"post_id" integer
		)'
	@db.close
   end

get '/' do                       #Read SQL выбераем список постов
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
	erb :index
  end

get '/new' do
	erb :new
  end

post '/new' do
	content = params[:content]
        
	    if content.length <= 0
		@error = "Type post text!"
		return erb :new
		end
	                            #Zapis w bazu	
		@db.execute 'INSERT INTO Posts (content, created_date) VALUES (?, datetime ())', [content]
	
	#erb "You typed: #{content}"
   
	redirect to '/' #Perenaprowlenie na glawnuy stronicu

  end


   #Wywod informacii o poste

get '/details/:post_id' do
	post_id = params[:post_id]
	
	results = @db.execute 'SELECT * FROM Posts Where id = ?', [post_id]
    @row = results[0]
    @comments = @db.execute 'SELECT * FROM Comments Where post_id = ? order by id', [post_id]

	erb :details
  end
 
post '/details/:post_id' do
	#Poluczaem peremennuy iz urla!
	post_id = params[:post_id]

	#Poluczaem peremennuy iz post-zaprosa
	content = params[:content]
	
	@db.execute 'INSERT INTO Comments (content, created_date, post_id) 
	VALUES (?, datetime (),?)', [content,post_id]
	  
	 erb redirect to('/details/' + post_id)
	#erb "You typed comment #{content} for post #{post_id}"
  end