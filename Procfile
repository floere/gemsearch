server: cd server; find / -name bundle 1>&2; bundle exec thin -R config.ru -p 8080 start
web:    cd client; find / -name bundle 1>&2; bundle exec ruby app.rb -p $PORT