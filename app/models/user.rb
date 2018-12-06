class User < ApplicationRecord
  has_many :transactions

  validates :external_id, :name, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :show_inspire_me

  def self.get(id, name: nil, recipe_data: nil)
    user = User.find_or_initialize_by(external_id: id)

    if user.new_record?
      user.name = name
      user.balance = 10 if user.new_record?
      user.save
    end

    if recipe_data
      value = ['yes', 'no', 'paid'].sample
      meta = {}
      meta = { coins: 100, recipe_id: 999 } if value == 'paid'

      user.show_inspire_me = {
        value: value,
        meta: meta
      }
    end

    user
  end
end
