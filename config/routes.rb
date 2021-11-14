Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  namespace :api do
    # Users
    resource :users, only: [:create]
    post :login, to: 'users#login'

    # Faxes
    resources :faxes
    post :webhook, to: 'faxes#webhook'
  end
end