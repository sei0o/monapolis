class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.integer :city_id, null: false

      t.timestamps null: false
    end

    add_index :topics, :title, unique: true
  end
end
