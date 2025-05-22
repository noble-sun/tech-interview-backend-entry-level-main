require "rails_helper"

RSpec.describe AddProductToCartService, type: :service do
  describe ".call" do
    context "add a new product to cart" do
      it "successfully" do
        product = create(:product, price: 10.0)
        cart = create(:cart)

        result = described_class.call(cart:, product_id: product.id, quantity: 2)

        cart.reload
        expect(result).to be_truthy
        expect(cart.cart_items.count).to eq(1)
        expect(cart.total_price).to eq(20.0)

        item = cart.cart_items.last
        expect(item.product).to eq(product)
        expect(item.quantity).to eq(2)
        expect(item.unit_price).to eq(product.price)
        expect(item.total_price).to eq(20.0)
      end
    end

    context "when product does not exist" do
      it "raises error" do
        cart = create(:cart)

        expect { described_class.call(cart:, product_id: 123, quantity: 2) }
          .to raise_error(ProductNotFoundError)

        cart.reload
        expect(cart.cart_items.count).to eq(0)
      end
    end
  end
end
