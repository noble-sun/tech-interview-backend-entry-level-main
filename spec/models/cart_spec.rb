require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end


    context "validates presence" do
      it "status" do
        cart = described_class.new(status: nil)

        expect(cart.valid?).to be_falsey
        expect(cart.errors[:status]).to include("can't be blank")
      end

      it "total_price" do
        cart = described_class.new(total_price: nil)

        expect(cart.valid?).to be_falsey
        expect(cart.errors[:total_price]).to include("can't be blank")
      end

      context "last_interaction_at" do
        it 'does not validate for new records' do
          cart = described_class.new(status: :active, total_price: 0.0)
          expect(cart.valid?).to be_truthy
        end

        it 'validate for existing records' do
          cart = create(:shopping_cart)
          cart.last_interaction_at = nil

          expect(cart.valid?).to be_falsey
          expect(cart.errors[:last_interaction_at]).to include("can't be blank")
        end
      end
    end
  end

  describe '#mark_as_abandoned' do
    context "whne last interaction happened more than 3 hours ago" do
      let(:shopping_cart) { create(:shopping_cart) }

      it 'marks the shopping cart as abandoned if inactive for a certain time' do
        shopping_cart.update(last_interaction_at: 3.hours.ago)
        expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
      end
    end

    context "whne last interaction happened less than 3 hours ago" do
      let(:shopping_cart) { create(:shopping_cart) }

      it 'do not mark cart as abandoned' do
        shopping_cart.update(last_interaction_at: 2.hours.ago)
        expect { shopping_cart.mark_as_abandoned }.to_not change { shopping_cart.abandoned? }
      end
    end
  end

  describe '#remove_if_abandoned' do
    context "when last interaction happened more than 7 days ago" do
      let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

      it 'removes the shopping cart if abandoned for a certain time' do
        shopping_cart.mark_as_abandoned
        expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
      end
    end

    context "when last interaction happened less than 7 days ago" do
      let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 6.days.ago) }

      it "does not remove the shopping cart" do
        shopping_cart.mark_as_abandoned
        expect { shopping_cart.remove_if_abandoned }.to_not change { Cart.count }
      end
    end

    context "when the shopping cart is not abandoned" do
      let!(:shopping_cart) { create(:shopping_cart, last_interaction_at: 2.hours.ago) }

      it "does not remove the shopping cart" do
        expect { shopping_cart.remove_if_abandoned }.to_not change { Cart.count }
      end
    end
  end

  describe "#add_or_update_cart_item" do
    context "when adding new product to cart" do
      it "create cart_item with given quantity" do
        cart = create(:shopping_cart)
        product = create(:product)

        time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
        travel_to(time_of_action) do
          expect {
            cart.add_or_update_cart_item(product:, quantity: 2)
          }.to change { CartItem.count }.by(1)
        end

        expect(cart.total_price).to eq(CartItem.last.total_price)
        expect(cart.last_interaction_at).to eq(time_of_action)
      end
    end

    context "when adding a product that already is in the cart" do
      it "updates product quantity" do
        cart = create(:shopping_cart)
        product = create(:product)
        cart_item = create(:cart_item, cart:, product:, quantity: 1,
          unit_price: product.price, total_price: product.price
        )

        time_of_action = Time.zone.local(2025, 12, 31, 23, 59, 59)
        travel_to(time_of_action) do
          expect {
            cart.add_or_update_cart_item(product:, quantity: 2)
          }.to change { cart_item.reload.quantity }.by(2)
        end

        cart_item.reload
        expect(CartItem.count).to eq(1)
        expect(cart.total_price).to eq(cart_item.total_price)
        expect(cart.last_interaction_at).to eq(time_of_action)
      end

      context "when removing a quantity of a existing product" do
        context "when current quantity is higher than removing quantity" do
          it "updates product quantity" do
            cart = create(:shopping_cart)
            product = create(:product)
            cart_item = create(:cart_item, cart:, product:, quantity: 5,
              unit_price: product.price, total_price: product.price
            )

              expect {
                cart.add_or_update_cart_item(product:, quantity: -2)
              }.to change { cart_item.reload.quantity }.from(5).to(3)

            expect(cart.total_price).to eq(CartItem.last.total_price)
          end
        end

        context "when current quantity is lower or equal to removing quantity" do
          it "removes cart_item" do
            cart = create(:shopping_cart)
            product = create(:product)
            cart_item = create(:cart_item, cart:, product:, quantity: 1,
              unit_price: product.price, total_price: product.price
            )

            expect {
              cart.add_or_update_cart_item(product:, quantity: -1)
            }.to change { cart.cart_items.count }.by(-1)

            expect(cart.total_price).to eq(0.0)
            expect(CartItem.count).to eq(0)
          end
        end
      end
    end
  end
end
