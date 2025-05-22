class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, null: false, precision: 17, scale: 2
      t.decimal :total_price, null: false, precision: 17, scale: 2

      t.timestamps
    end
  end
end
