require 'sinatra'
require 'pg'
require 'bcrypt'
require 'sinatra/reloader' if development?
# require 'pry'
require 'money'

Money.locale_backend = :currency

require_relative 'database/data_access'
 

enable :sessions

def logged_in?()
  session[:user_id]
end

def investor_logged_in?()
  session[:user_id][:type] == 'investor'
end

def current_user()
  find_user_by_id(session[:user_id])
end


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
    password_digest,
  0)
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
    password_digest,
  0)
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

get '/investor' do
  erb :investor_home
end

post '/invest/:id' do
    if total_investor_wallet(session[:user_id][:id]).to_i > params['value_loan'].to_i
      investor_lender_loan(params['id'], params['id_debtor'], params['value_loan'], params['id_loan'])
      redirect '/investor'
  end
    erb :insufficient_funds
end


patch '/investor.wallet/:id' do

  params['button'] == 'boost' ? update_investor_wallet_boost(params['value'].gsub(/[\s,]/ ,"").gsub(/\.00/mi ,''), params['id']) : update_investor_wallet_withdraw(params['value'].gsub(/[\s,]/ ,"").gsub(/\.00/mi ,''), params['id'])
  redirect '/user.profile'
end

patch '/debtor.wallet/:id' do
  if total_debtor_wallet(session[:user_id][:id]).to_i > params['value'].to_i
    update_debtor_wallet_withdraw(params['value'].gsub(/[\s,]/ ,"").gsub(/\.00/mi ,''), params['id'])
    redirect '/debtor'
  end
  erb :insufficient_funds 
end

get '/user.profile' do
   
  if session[:user_id][:type] == 'investor'
    erb :investor_profile, locals: {id_investor: session[:user_id][:id].to_i}
  else
    erb :debtor_profile, locals: {id_debtor: session[:user_id][:id].to_i}
  end
end


post '/installment/:id' do
  pay_installment(params['value'], params['id_investor'].to_i, params['id_installment'].to_i)
  
  redirect 'debtor'
end
