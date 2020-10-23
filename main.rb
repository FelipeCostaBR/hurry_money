require 'sinatra'
require 'pg'
require 'bcrypt'
 require 'sinatra/reloader' if development?
 require 'pry'

require_relative 'database/data_access'
 also_reload 'database/data_access'

enable :sessions
# ################### ################### ##################

def logged_in?()
  session[:user_id]
end

# can only use this if is logged in
def current_user()
  find_user_by_id(session[:user_id])
end

# ################### ################### ##################

get '/' do
  erb :index
end

get '/login' do
  erb :login
end

post '/login' do
  params['user-type']== "investor" ? user = find_investor_by_email(params['email']) : user = find_debtor_by_email(params['email'])
  if user.empty?
    'Wrong email'
  else
    if BCrypt::Password.new(user['password_digest']).==(params['password'])
      session[:user_id] = {id: user['id'], type: user['type']}
       if params['user-type'] == "investor" 
        redirect '/investor' 
       else 
        redirect '/debtor'
       end
    else
      erb :login
    end
  end
end

post '/user' do
  password_digest = BCrypt::Password.create(params['password'])

  if params['user-type'] == "investor"
    create_investor(
    params['firstName'],
    params['lastName'],
    params['email'], 
    params['phone'], 
    params['date_birth'], 
    params['address'], 
    params['photo'],
    password_digest)
    user = find_investor_by_email(params['email'])
  else 
    create_debtor(
    params['firstName'], 
    params['lastName'], 
    params['email'],  
    params['phone'], 
    params['date_birth'], 
    params['address'], 
    params['photo'],
    password_digest)
    user = find_debtor_by_email(params['email'])
  end
  
  session[:user_id] = {id: user['id'], type: user['type']}

  if params['user-type'] == "investor" 
    redirect '/investor' 
   else 
    redirect '/debtor'
   end
  
end

delete '/logout' do
  #destroy the session
  session[:user_id]= nil    
  redirect '/login'
end


get '/sign.up' do
  erb :sign_up
end

get '/debtor' do
  erb :debtor_home
end

post '/apply_loan/:id' do
  if params['installment'] == "24" 
    params['installment'] = 1 
  elsif params['installment'] == "28"
    params['installment'] = 2 
  else
    params['installment'] = 3
  end
  apply_loan(params['loan_asked'], params['fee'], params['installment'], params['id'])
    redirect '/debtor'
end