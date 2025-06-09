class RemoveItemFromCartService
  def self.call(cart:, product_id:)
    new(cart:, product_id:).call
  end

  def initialize(cart:, product_id:)
    @cart = cart
    @product_id = product_id
  end

  def call
    remove_product_from_cart
  end

  private

  attr_reader :cart, :product_id

  def remove_product_from_cart
    item = cart.cart_items.find_by(product_id:)
    raise ProductNotInCartError unless item

    ActiveRecord::Base.transaction do
      item.destroy!
      cart.recalculate_total_price
      cart.touch_last_interaction_at
      cart.save!

      cart
    end
  end
end
