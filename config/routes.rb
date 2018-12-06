Rails.application.routes.draw do
  root "status#index"
  resources :users, only: [:show]
end
