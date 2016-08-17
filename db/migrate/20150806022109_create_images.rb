class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :storage
      t.string :flag

      t.timestamps null: false
    end
  end
end
