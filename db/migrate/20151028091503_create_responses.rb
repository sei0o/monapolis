class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :body, null: false

      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :city_id, null: false

      t.timestamps null: false
    end
  end
end
