Rails.application.routes.draw do
  root 'home#index'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'
  resources :sessions, only: %i[create destroy]

  get 'user_answers/submit', to: 'user_answers#submit'
  get 'user_answers/results', to: 'user_answers#results'
  resources :user_answers, only: %i[new create edit update index]
end
