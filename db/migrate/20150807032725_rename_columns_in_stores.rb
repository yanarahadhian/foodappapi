class RenameColumnsInStores < ActiveRecord::Migration
  def change
    rename_column :stores, :city, :street
  end
end
