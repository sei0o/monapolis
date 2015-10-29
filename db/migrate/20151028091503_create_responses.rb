class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :body, null: false
      t.decimal :received_mona, precision: 15, scale: 8, default: 0.0, null: false

      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :city_id, null: false

      t.timestamps null: false
    end
  end
end
