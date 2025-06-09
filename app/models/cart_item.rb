class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates_presence_of :quantity, :unit_price, :total_price
  validates_numericality_of :unit_price, :total_price, greater_than_or_equal_to: 0
  validates_numericality_of :quantity, greater_than_or_equal_to: 1

  def update_quantity_and_derived_prices!(quantity:)
    raise MissingProductError, I18n.t('errors.missing_product') unless product

    price = product.price
    update!(quantity:, unit_price: price, total_price: price * quantity)
  end
end
