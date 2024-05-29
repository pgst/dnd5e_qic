Rails.application.routes.draw do
  root 'home#index'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'
  resources :sessions, only: %i[create destroy]

  # get 'home/index', to: 'home#index'
end
