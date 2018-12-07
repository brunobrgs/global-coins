class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :origin_transaction, class_name: 'Transaction', foreign_key: 'transaction_id', required: false

  has_one :destiny_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
  has_one :destiny_user, through: :destiny_transaction, source: :user

  validates :user_id, :amount, :operation, :status, presence: true
  validates :email, presence: { if: :remove_operation? }
  validates :status, inclusion: { in: %w(pending success failed) }
  validates :operation, inclusion: { in: %w(add remove transfer) }

  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: "success") }

  def details
    case operation
    when "add" then
      if payment_id
        "Congratulations. You have added #{amount} coins to your account."
      else
        "You received #{amount} coins as gift from Cookpad."
      end
    when "remove" then
      "Money for you! You have redeemed #{amount.abs} coins."
    when "transfer" then
      if origin_transaction
        "You received #{amount.abs} coins from #{origin_transaction.user.name}"
      else
        "You sent #{amount.abs} coins to #{destiny_user.name}"
      end
    end
  end

  def make(destination_user_id: nil, destination_user_name: nil, payment_response_url: nil)
    return unless valid?
    raise "amount needs to be positive" if amount <= 0

    ApplicationRecord.transaction do
      case operation
      when "add" then
        make_add(payment_response_url)
      when "remove"
        make_remove
      when "transfer" then
        make_transfer(destination_user_id, destination_user_name)
      else
        raise "invalid operation"
      end
    end

    self
  rescue RuntimeError, ActiveRecord::RecordInvalid => e
    self.status = "failed"
    self.errors.add(:base, e.to_s)
  end

  private

  def remove_operation?
    operation == "remove"
  end

  def abs_amount
    amount.abs
  end

  def make_transfer(destination_user_id, destination_user_name)
    destination_user = User.get(destination_user_id, name: destination_user_name)
    raise "Destination user not found" if destination_user.new_record?

    self.amount = - abs_amount
    self.status = "success"
    self.save!

    user.balance -= abs_amount
    user.save!

    destiny_transaction = Transaction.new
    destiny_transaction.user = destination_user
    destiny_transaction.transaction_id = id
    destiny_transaction.amount = abs_amount
    destiny_transaction.operation = operation
    destiny_transaction.status = status
    destiny_transaction.save!

    destination_user.balance += abs_amount
    destination_user.save!
  end

  def make_add(payment_response_url)
    self.amount = abs_amount
    self.save!

    PaypalPayment.call(self, return_url: payment_response_url)
  end

  def make_remove
    raise "You need to have at least 10 coins to redeem" if abs_amount < 10

    self.amount = -abs_amount
    self.save!

    user.balance -= abs_amount
    user.save!

    PaypalPayout.call(self)
  end
end
