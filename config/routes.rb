Rails.application.routes.draw do
  root "status#index"
  resources :users, only: [:show]
  resources :transactions, only: [:index, :show, :create]
end
