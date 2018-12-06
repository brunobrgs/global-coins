class UsersController < ApplicationController
  def show
    user = User.get(params[:id], name: params[:name], recipe_data: params[:recipe_data])
    if user.persisted?
      render json: { balance: user.balance, show_inspire_me: user.show_inspire_me }
    else
      render json: { errors: errors(user) }, status: 422
    end
  end
end
