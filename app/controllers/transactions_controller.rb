class TransactionsController < ApplicationController
  def index
    @transactions = user.transactions.recent
  end

  def show
    @transaction.find(params[:id])
  end

  def create
    transaction = user.transactions.new(transaction_params)
    transaction.make(destination_user_id: params[:destination_user_id], return_url: payment_response_url)
    if transaction.persisted?
      render json: { id: transaction.id }
    else
      render json: { errors: errors(transaction) }, status: 422
    end
  end

  def payment_response
    # PaypalConfirmation.call(params)
    # render nothing: true
  end

  private

  def user
    @_user ||= User.find_by(external_id: params[:user_id])
  end

  def transaction_params
    params.permit(:amount, :operation, :recipe_id)
  end
end