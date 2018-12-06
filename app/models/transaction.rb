class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :origin_transaction, class_name: 'Transaction', foreign_key: 'transaction_id', required: false

  has_one :destiny_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
  has_one :destiny_user, through: :destiny_transaction, source: :user

  validates :user_id, :amount, :operation, :status, presence: true
  validates :status, inclusion: { in: %w(pending success failed) }
  validates :operation, inclusion: { in: %w(add remove transfer) }

  scope :recent, -> { order(created_at: :desc) }

  def details
    case operation
    when "add" then
      "Coins added"
    when "remove" then
      "Coins removed"
    when "transfer" then
      if origin_transaction
        "#{amount} coins received from #{origin_transaction.user.name}"
      else
        "#{amount} coins sent to #{destiny_user.name}"
      end
    end
  end

  def make(destination_user_id: nil, payment_response_url: nil)
    return unless valid?
    raise "amount needs to be positive" if amount <= 0

    ApplicationRecord.transaction do
      case operation
      when "add" then
        make_add(payment_response_url)
      when "transfer" then
        make_transfer(destination_user_id)
      else
        raise "invalid operation"
      end
    end

    self
  rescue RuntimeError => e
    self.errors.add(:base, e.to_s)
  end

  private

  def abs_amount
    amount.abs
  end

  def make_transfer(destination_user_id)
    destination_user = User.find_by(external_id: destination_user_id)
    raise "Destination user not found" if destination_user.blank?

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
end
