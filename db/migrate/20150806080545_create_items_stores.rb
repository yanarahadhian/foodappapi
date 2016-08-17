class CreateItemsStores < ActiveRecord::Migration
  def change
    create_table :items_stores, :id => false do |t|
      t.references :item, index: true, foreign_key: true
      t.references :store, index: true, foreign_key: true
    end
  end
end
