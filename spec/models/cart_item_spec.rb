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

  context "before_validation" do
    context ":set_total_price" do
      it "sets total_price based on unit_price and quantity" do
        cart = create(:cart)
        product = create(:product)
        cart_item = described_class.new(cart:, product:, unit_price: 10, quantity: 2)

        expect(cart_item.valid?).to be_truthy
        expect(cart_item.total_price).to eq(20.0)
      end

      context "when unit_price or quantity is nil" do
        it "does not raise error" do
          cart = create(:cart)
          product = create(:product)
          cart_item = described_class.new(cart:, product:)

          expect { cart_item.valid? }.to_not raise_error
        end
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
      it 'total_price' do
        cart = described_class.new(total_price: -1)

        expect(cart.valid?).to be_falsey
        expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
      end

      it 'unit_price' do
        cart = described_class.new(unit_price: -1)
        
        expect(cart.valid?).to be_falsey
        expect(cart.errors[:unit_price]).to include("must be greater than or equal to 0")
      end

      it 'quantity' do
        cart = described_class.new(quantity: -1)
        expect(cart.valid?).to be_falsey
        expect(cart.errors[:quantity]).to include("must be greater than or equal to 0")
      end
    end
  end
end
