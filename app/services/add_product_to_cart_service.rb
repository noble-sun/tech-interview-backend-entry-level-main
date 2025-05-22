class AddProductToCartService
  def self.call(cart:, product_id:, quantity:)
    new(cart:, product_id:, quantity:).call
  end

  def initialize(cart:, product_id:, quantity:)
    @cart = cart
    @product_id = product_id
    @quantity = quantity
  end

  def call
    add_product_to_cart

    true
  end

  private

  attr_reader :cart, :product_id, :quantity

  def add_product_to_cart
    product = Product.find_by(id: product_id)

    raise ProductNotFoundError unless product

    cart.add_product(product:, quantity:)
  end
end
