require "rails_helper"

RSpec.describe AddOrUpdateCartItemService, type: :service do
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

      context "when the is a different product on the cart" do
        it "create a new cart_item for the new product" do
          product = create(:product, price: 10.0)
          cart = create(:cart)
          create(:cart_item, cart:, product:, quantity: 2, unit_price: product.price, total_price: 20.0)
          product_not_on_cart = create(:product, price: 15.0)

          result = described_class.call(cart:, product_id: product_not_on_cart.id, quantity: 2)

          cart.reload
          expect(result).to be_truthy
          expect(cart.cart_items.count).to eq(2)
          expect(cart.total_price).to eq(50.0)

          item = cart.cart_items.last
          expect(item.product).to eq(product_not_on_cart)
          expect(item.quantity).to eq(2)
          expect(item.unit_price).to eq(product_not_on_cart.price)
          expect(item.total_price).to eq(30.0)
        end
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

    context "when there is already the same product on the cart" do
      it "update and sum the current quantity on the cart_item" do
        cart = create(:cart, total_price: 20.0)
        product = create(:product, price: 10.0)
        create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0) 

        result = described_class.call(cart:, product_id: product.id, quantity: 1)

        cart.reload
        expect(result).to be_truthy
        expect(cart.cart_items.count).to eq(1)
        expect(cart.total_price).to eq(30.0)
        expect(cart.cart_items.last.quantity).to eq(3)
        expect(cart.cart_items.last.total_price).to eq(30.0)
      end

      context "when removing quantity from the product" do
        context "when quantity is bigger than current quantity" do
          it "remove product from cart" do
            cart = create(:cart, total_price: 20.0)
            product = create(:product, price: 10.0)
            create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0)

            result = described_class.call(cart:, product_id: product.id, quantity: -1)

            cart.reload
            expect(result).to be_truthy
            expect(cart.cart_items.count).to eq(1)
            expect(cart.total_price).to eq(10.0)
            expect(cart.cart_items.last.quantity).to eq(1)
            expect(cart.cart_items.last.total_price).to eq(10.0)
          end
        end

        context "when quantity is less or equal to current quantity" do
          it "remove product from cart" do
            cart = create(:cart, total_price: 20.0)
            product = create(:product, price: 10.0)
            create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0)

            result = described_class.call(cart:, product_id: product.id, quantity: -2)

            cart.reload
            expect(result).to be_truthy
            expect(cart.cart_items.count).to eq(0)
            expect(cart.total_price).to eq(0.0)
          end
        end
      end
    end
  end
end
