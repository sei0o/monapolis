class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :sender_user_id
      t.integer :receiver_user_id
      t.integer :receiver_response_id
      t.decimal :amount, precision: 15, scale: 8, default: 0.0, null: false
      t.integer :type, null: false

      t.timestamps null: false
    end
  end
end
