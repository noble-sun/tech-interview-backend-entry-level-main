require "rails_helper"

RSpec.describe AddOrUpdateCartItemService, type: :service do
  describe ".call" do
    context "add a new product to cart" do
      context "add cart_item and update total_price and last interaction" do
        it "successfully" do
          product = create(:product, price: 10.0)
          cart = create(:cart)

          time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
          travel_to(time_of_action) do
            described_class.call(cart:, product_id: product.id, quantity: 2)
          end

          cart.reload
          expect(cart.last_interaction_at).to eq(time_of_action)
          expect(cart.cart_items.count).to eq(1)
          expect(cart.total_price).to eq(20.0)

          item = cart.cart_items.last
          expect(item.product).to eq(product)
          expect(item.quantity).to eq(2)
          expect(item.unit_price).to eq(product.price)
          expect(item.total_price).to eq(20.0)
        end
      end

      context "when there is a different product on the cart" do
        it "create a new cart_item for the new product" do
          product = create(:product, price: 10.0)
          cart = create(:cart)
          create(:cart_item, cart:, product:, quantity: 2, unit_price: product.price, total_price: 20.0)
          product_not_on_cart = create(:product, price: 15.0)

          result = described_class.call(cart:, product_id: product_not_on_cart.id, quantity: 2)

          cart.reload
          expect(result).to be_an_instance_of(CartItem)
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
        expect(result).to be_an_instance_of(CartItem)
        expect(cart.cart_items.count).to eq(1)
        expect(cart.total_price).to eq(30.0)
        expect(cart.cart_items.last.quantity).to eq(3)
        expect(cart.cart_items.last.total_price).to eq(30.0)
      end

      context "when removing quantity from the product" do
        context "when final quantity is bigger than zero" do
          it "update cart_item quantity and prices" do
            cart = create(:cart, total_price: 20.0)
            product = create(:product, price: 10.0)
            create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0)

            result = described_class.call(cart:, product_id: product.id, quantity: -1)

            cart.reload
            expect(result).to be_an_instance_of(CartItem)
            expect(cart.cart_items.count).to eq(1)
            expect(cart.total_price).to eq(10.0)
            expect(cart.cart_items.last.quantity).to eq(1)
            expect(cart.cart_items.last.total_price).to eq(10.0)
          end
        end

        context "when final quantity is less or equal to zero" do
          it "remove product from cart" do
            cart = create(:cart, total_price: 20.0)
            product = create(:product, price: 10.0)
            create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0)

            time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
            travel_to(time_of_action) do
              result = described_class.call(cart:, product_id: product.id, quantity: -2)
              expect(result).to be_nil
            end

            cart.reload
            expect(cart.last_interaction_at).to eq(time_of_action)
            expect(cart.cart_items.count).to eq(0)
            expect(cart.total_price).to eq(0.0)
          end
        end
      end
    end

    context "when something fail and transaction does not complete" do
      it "raise error and rollback changes" do
        last_interaction_at = Time.zone.local(2025, 01, 01, 0, 0, 0)
        cart = create(:cart, total_price: 20.0, last_interaction_at:)
        product = create(:product, price: 10.0)
        create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0)

        allow_any_instance_of(Cart).to receive(:save!)
          .and_raise(ActiveRecord::ConnectionNotEstablished)

        time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
        travel_to(time_of_action) do
          expect {
            described_class.call(cart:, product_id: product.id, quantity: -10)
          }.to raise_error(ActiveRecord::ConnectionNotEstablished)
        end

        cart.reload
        expect(cart.last_interaction_at).to_not eq(time_of_action)
        expect(cart.cart_items.count).to eq(1)
        expect(cart.total_price).to eq(20.0)
        expect(cart.cart_items.last.quantity).to eq(2)
        expect(cart.cart_items.last.total_price).to eq(20.0)
      end
    end
  end
end
