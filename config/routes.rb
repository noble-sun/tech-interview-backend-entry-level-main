require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products

  post "carts/add_items", to: "carts#add_items"

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
