class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :user, index: true, foreign_key: true
      t.references :item_category, index: true, foreign_key: true
      t.string :name
      t.float :delivery_fee
      t.float :price
      t.string :country
      t.string :city
      t.text :description

      t.timestamps null: false
    end
  end
end
