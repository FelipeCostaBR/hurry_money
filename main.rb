     
require 'sinatra'
require 'pg'
require 'bcrypt'
'sinatra/reloader' if development?
# also_reload '' if development?



def run_sql(sql)
  result = PG.connect(ENV['DATABASE_URL'] || {dbname: 'hurrymoney'}).exec(sql)
  db.close
  return result
end


get '/' do
  erb :index
end





