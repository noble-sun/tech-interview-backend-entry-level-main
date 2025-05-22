class CartItem < ApplicationRecord
  belongs_to :cart
  has_one :product

  validates_presence_of :quantity, :unit_price, :total_price
  validates_numericality_of :unit_price, :total_price, :quantity, greater_than_or_equal_to: 0
end
