require "rails_helper"

RSpec.describe CartItem, type: :model do
  context "associations" do
    context "cart" do
      it "can be associated" do
        cart = create(:cart)

        cart_item = described_class.new(cart:, quantity: 1, unit_price: 1.0)

        expect(cart_item.cart).to eq(cart)
      end
    end

    context "product" do
      it "can be associated" do
        product = create(:product)

        cart_item = described_class.new(product:, quantity: 1, unit_price: 1.0)

        expect(cart_item.product).to eq(product)
      end
    end
  end

  context "validate" do
    context "presence" do
      it "quantity" do
        cart_item = described_class.new(quantity: nil)

        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:quantity]).to include("can't be blank")
      end

      it "unit_price" do
        cart_item = described_class.new(unit_price: nil)

        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:unit_price]).to include("can't be blank")
      end

      it "total_price" do
        cart_item = described_class.new(total_price: nil)

        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:total_price]).to include("can't be blank")
      end
    end

    context "numeriality" do
      it "total_price" do
        cart_item = described_class.new(total_price: -1)

        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:total_price]).to include("must be greater than or equal to 0")
      end

      it "unit_price" do
        cart_item = described_class.new(unit_price: -1)
        
        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:unit_price]).to include("must be greater than or equal to 0")
      end

      it "quantity" do
        cart_item = described_class.new(quantity: -1)
        expect(cart_item.valid?).to be_falsey
        expect(cart_item.errors[:quantity]).to include("must be greater than or equal to 1")
      end
    end
  end

  describe "#update_quantity_and_derived_prices!" do
    context "update unit_price and total_price based on associated product" do
      it "successfully" do
        cart = create(:cart)
        product = create(:product, price: 10.0)
        cart_item = described_class.new(cart:, product:, unit_price: 10.0, quantity: 2)

        cart_item.update_quantity_and_derived_prices!(quantity: 3)
        expect(cart_item.quantity).to eq(3)
        expect(cart_item.unit_price).to eq(10.0)
        expect(cart_item.total_price).to eq(30.0)
      end

      context "whne product is not associated" do
        it "raise error" do
          cart = create(:cart)
          cart_item = described_class.new(cart:)

          expect { cart_item.update_quantity_and_derived_prices!(quantity: 1) }
            .to raise_error(MissingProductError, "Cannot set pricing: product must be present")
        end
      end
    end
  end
end
