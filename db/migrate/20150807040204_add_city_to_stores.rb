class AddCityToStores < ActiveRecord::Migration
  def change
    add_column :stores, :city, :string
  end
end
