class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :website_url, :string
    add_column :users, :about_me, :text
  end
end
