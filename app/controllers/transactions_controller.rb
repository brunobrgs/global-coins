class TransactionsController < ApplicationController
  def index
    @user = user
    @transactions = user.transactions.recent.includes(:destiny_user)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def create
    transaction = user.transactions.new(transaction_params)
    transaction.make(
      destination_user_id: params[:destination_user_id],
      destination_user_name: params[:destination_user_name],
      payment_response_url: payment_response_transactions_url
    )
    if transaction.persisted?
      render json: { id: transaction.id, url: transaction.approval_url }
    else
      render json: { errors: errors(transaction) }, status: 422
    end
  end

  def payment_response
    PaypalConfirmation.call(params)
    redirect_to "http://www.cookpad.com"
  end

  private

  def user
    @_user ||= User.get(params[:user_id], name: params[:user_name])
  end

  def transaction_params
    params.permit(:amount, :operation, :recipe_id, :description, :email)
  end
end
