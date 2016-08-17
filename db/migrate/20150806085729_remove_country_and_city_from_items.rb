class RemoveCountryAndCityFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :country, :string
    remove_column :items, :city, :string
  end
end
