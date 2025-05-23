class AddStatusAndDefaultTotalPriceValueToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string, default: 'active', null: false
    change_column_default :carts, :total_price, from: nil, to: 0
  end
end
