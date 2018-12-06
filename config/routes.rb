Rails.application.routes.draw do
  root "status#index"
  resources :users, only: [:show]
  resources :transactions, only: [:index, :show, :create] do
    get :payment_response, on: :collection, as: :payment_response
  end
end
