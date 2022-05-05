require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS
      "Users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "username" TEXT, "phone" TEXT, "datastamp" TEXT,
      "master" TEXT, "color" TEXT);'
end

get '/' do
  @title = "Barbershop"
  erb "Greeting you in our barbershop!"
end

get '/about' do
  @title = "О нас"
  @error = 'Something wrong!'
  erb :about
end

get '/contacts' do
  @title = 'Контакты'
  erb :contacts
end

post '/contacts' do
        @user_email = params[:user_email] # получить, то что отправил браузер
        @user_message = params[:user_message] # получить, то что отправил браузер

        @title = 'Контакты'
        @message = 'Информация успешно отправлена!'

        output = File.open('./public/contacts.txt', 'a')
        output.write "User email: #{@user_email}, user message: #{@user_message}\n"
        output.close

        erb :message
end

get '/visit' do
  @title = "Записаться"
  erb :visit
end

post '/visit' do
        @user_name = params[:user_name] # получить, то что отправил браузер со страницы visit.erb <input name="user_name" type="text" class="form-control" placeholder="Введите Ваше имя">
        @user_phone = params[:user_phone] # получить, то что отправил браузер со страницы visit.erb <input name="user_phone" type="text" class="form-control" placeholder="Номер Вашего телефона">
        @date_time = params[:date_time] # получить, то что отправил браузер со страницы visit.erb <input name="date_time" type="text" class="form-control" placeholder="Введите дату и время">
        @master = params[:master] # получить, то что отправил браузер со страницы visit.erb <select name="master" class="form-select" aria-label="Default select example">
        @color = params[:color] # получить, то что отправил браузер со страницы visit.erb <select id="color" name="color">

        @title = 'Записаться'
        @info = 'Вы записались!'
        @message = "#{@user_name}, мы Вас ждем #{@date_time}. Ваш мастер #{@master}. Цвет окраски волос: #{@color}!"

        output = File.open('./public/visits.txt', 'a')
        output.write "User: #{@user_name}, Phone: #{@user_phone}, Date and time: #{@date_time}, master: #{@master}, color: #{@color}\n"
        output.close

        # хэш с пара ключ-значение (символ-значение ошибки)
        hash_error = { :user_name => 'Введите имя!',
                       :user_phone => 'Введите номер телефона!',
                       :date_time => 'Неправильная дата и время!' }
=begin
        # Вариант №1
        # для каждой пары ключ-значение
        hash_error.each do |key, value|

          # если параметр пуст
          if params[key] == ''
            # переменной error присвоить value из хэша hash_error
            # (value - из хэша hash_error это сообщение об ошибке)
            # т.е. переменной error присвоить сообщение об ошибке
            @error = hash_error[key]

            # вернуть представление visit
            return erb :visit
          end
        end
=end

        # Вариант №2
        @error = hash_error.select {|key,_| params[key] == ""}.values.join(" ")

        if @error != ''
          return erb :visit
        end

        db = get_db
        db.execute 'insert into Users (username, phone, datastamp, master, color)
                    values (?, ?, ?, ?, ?)', [@user_name, @user_phone, @date_time, @master, @color]

        erb :message
end

get '/showusers' do
  @users = get_db
  erb :showusers
end

not_found do
  erb :not_found
end
