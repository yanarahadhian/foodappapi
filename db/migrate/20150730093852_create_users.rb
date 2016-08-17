class CreateUsers < ActiveRecord::Migration
  def change
    # if Rails.env.staging?
    #   add_column :users, :access_token, :string
    #   rename_column :users, :password, :password_digest
    # else
      create_table :users do |t|
        t.string :email
        t.string :password_digest
        t.string :access_token

        t.timestamps :null => false
      end
    # end

    add_index :users, :email, :unique => true
    add_index :users, :access_token, :unique => true
  end
end
