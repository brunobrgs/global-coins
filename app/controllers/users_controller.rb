class UsersController < ApplicationController
  def show
    user = User.get(params[:id], name: params[:name])
    if user.persisted?
      render json: { balance: user.balance }
    else
      render json: { errors: errors(user) }, status: 422
    end
  end
end
