class AddIndexToCartStatus < ActiveRecord::Migration[7.1]
  def change
    add_index :carts, :status
  end
end
