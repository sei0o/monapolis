class RemoveCityIdOfResponse < ActiveRecord::Migration
  def change
    remove_column :responses, :city_id
  end
end
