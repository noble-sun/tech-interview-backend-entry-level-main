class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0, if: -> { cart_items.any? }

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def add_product(product:, quantity:)
    item = cart_items.find_or_initialize_by(product_id: product.id)
    item.update!(quantity:, unit_price: product.price)

    recalculate_total_price!
  end

  def recalculate_total_price!
    self.total_price = cart_items.sum(:total_price)
    save!
  end
end
