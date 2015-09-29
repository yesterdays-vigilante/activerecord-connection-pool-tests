Rails.application.routes.draw do
  root 'home#index'
  get '/db_wait' => 'home#db_wait'
  get '/app_wait' => 'home#app_wait'
end
