class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :cities, :name, unique: true
    add_index :cities, :code, unique: true
  end
end
