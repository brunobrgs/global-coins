class Transaction < ApplicationRecord
  enum status: [:pending, :success, :failed]
  enum operation: [:add, :remove, :transfer]

  belongs_to :user

  validates :user_id, :amount, :operation, :status, presence: true
end
