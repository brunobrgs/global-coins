class User < ApplicationRecord
  has_many :transactions

  validates :external_id, :name, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def self.get(id, name: nil)
    user = User.find_or_initialize_by(external_id: id)

    if user.new_record?
      user.name = name
      user.balance = 10 if user.new_record?
      user.save
    end

    user
  end
end
