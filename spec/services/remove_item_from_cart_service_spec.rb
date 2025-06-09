require "rails_helper"

RSpec.describe RemoveItemFromCartService, type: :service do
  describe ".call" do
    context "remove an existing product from cart" do
      it "successfully" do
        cart = create(:cart, total_price: 20.0)
        product = create(:product, price: 10.0)
        quantity = 2
        create(:cart_item,
          cart:, product:, quantity:,
          unit_price: product.price,
          total_price: product.price * quantity
        )

        time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
        travel_to(time_of_action) do
          expect {
            described_class.call(cart:, product_id: product.id)
          }.to change(CartItem, :count).by(-1)
        end

        expect(cart.cart_items.count).to eq(0)
        expect(cart.total_price).to eq(0.0)
        expect(cart.last_interaction_at).to eq(time_of_action)
      end

      context "when something unexpected happens" do
        it "raise error and rollback changes" do
          last_interaction_at = Time.zone.local(2025, 01, 01, 0, 0, 0)
          cart = create(:cart, total_price: 20.0, last_interaction_at:)
          product = create(:product, price: 10.0)
          quantity = 2
          create(:cart_item,
            cart:, product:, quantity:,
            unit_price: product.price,
            total_price: product.price * quantity
          )
  
          allow_any_instance_of(Cart).to receive(:save!)
            .and_raise(ActiveRecord::ConnectionNotEstablished)
  
          time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
          travel_to(time_of_action) do
            expect {
              described_class.call(cart:, product_id: product.id)
            }.to raise_error(ActiveRecord::ConnectionNotEstablished)
          end
  
          cart.reload
          expect(cart.last_interaction_at).to_not eq(time_of_action)
          expect(cart.cart_items.count).to eq(1)
          expect(cart.total_price).to eq(20.0)
          expect(cart.cart_items.last.total_price).to eq(20.0)
  
        end
      end
    end

    context "when product is not in cart" do
      it "raise error" do
        cart = create(:cart, total_price: 20.0)

        expect{
          described_class.call(cart:, product_id: 9999)
        }.to raise_error(ProductNotInCartError)
      end
    end
  end
end
