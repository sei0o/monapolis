class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.text :description
      t.string :password, null: false
      t.string :password_salt, null: false

      t.timestamps null: false
    end

    add_index :users, :name, unique: true
  end
end
