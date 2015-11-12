class AddWalletAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wallet_address, :string, null: false
    add_index :users, :wallet_address, unique: true
  end
end
