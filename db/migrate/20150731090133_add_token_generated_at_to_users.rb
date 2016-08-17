class AddTokenGeneratedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_generated_at, :datetime
  end
end
