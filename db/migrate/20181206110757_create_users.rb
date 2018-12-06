class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :external_id, null: false, unique: true
      t.string :name
      t.integer :balance, null: false, default: 0

      t.timestamps
    end
  end
end
