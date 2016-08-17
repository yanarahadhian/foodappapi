class AddFacebookIdToUsers < ActiveRecord::Migration
  def change
    # add_column :users, :facebook_id, :string unless Rails.env.staging?
    add_column :users, :facebook_id, :string
  end
end
