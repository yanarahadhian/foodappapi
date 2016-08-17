class AddVerifiedFbToUsers < ActiveRecord::Migration
  def change
    # if Rails.env.staging?
    #   change_column :users, :verified_fb, :text
    # else
      add_column :users, :verified_fb, :text
    # end
  end
end
