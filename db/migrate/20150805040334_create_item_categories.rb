class CreateItemCategories < ActiveRecord::Migration
  def change
    create_table :item_categories do |t|
      t.string :name

      t.timestamps null: false
    # end unless Rails.env.staging?
    end
  end
end
