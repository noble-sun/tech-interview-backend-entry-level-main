class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates_presence_of :quantity, :unit_price, :total_price
  validates_numericality_of :unit_price, :total_price, :quantity, greater_than_or_equal_to: 0

  before_validation :set_total_price
  after_save :update_cart_total

  private

  def set_total_price
    self.total_price = unit_price * quantity
  end

  def update_cart_total
    cart.recalculate_total_price!
  end
end
