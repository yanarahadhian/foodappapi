class RemoveUserFromItems < ActiveRecord::Migration
  def change
    remove_reference :items, :user, index: true, foreign_key: true
  end
end
