class AddPaypalInfoToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payment_id, :string
    add_column :transactions, :approval_url, :string
  end
end
