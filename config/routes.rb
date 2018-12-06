Rails.application.routes.draw do
  root "status#index"
  resources :users, only: [:show]
  resources :transactions, only: [:index, :show, :create]
  match "transactions/payment_response" => "transactions#payment_response", as: :payment_response, via: [:get, :post]
end
