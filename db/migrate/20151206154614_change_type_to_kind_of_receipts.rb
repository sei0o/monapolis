class ChangeTypeToKindOfReceipts < ActiveRecord::Migration
  def change
    # see: http://stackoverflow.com/questions/1992019/how-can-i-rename-a-database-column-in-a-rails-migration
    rename_column :receipts, :type, :kind
  end
end
