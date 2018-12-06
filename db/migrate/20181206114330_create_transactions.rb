class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true, null: false
      t.integer :amount, null: false
      t.string :operation, null: false
      t.string :status, null: false, default: 'pending'
      t.integer :recipe_id
      t.integer :transaction_id

      t.timestamps
    end

    add_index :transactions, :status
  end
end
