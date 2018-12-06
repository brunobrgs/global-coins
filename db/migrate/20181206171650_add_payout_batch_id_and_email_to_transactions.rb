class AddPayoutBatchIdAndEmailToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :email, :string
    add_column :transactions, :payout_batch_id, :string
  end
end
