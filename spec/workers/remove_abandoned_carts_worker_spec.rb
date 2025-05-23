require "rails_helper"

RSpec.describe RemoveAbandonedCartsWorker, type: :worker do
  it 'enqueues job' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
  end

  describe "#perform" do
    context "when there are abandoned carts" do
      context "when it's been more than 7 days" do
        it "remove abandoned carts" do
          travel_to(7.days.ago) do
            create_list(:cart, 5, status: :abandoned)
          end

          create(:cart, status: :active)
          recent_abandoned_cart = create(:cart, status: :abandoned)

          described_class.new.perform

          expect(Cart.active.count).to eq(1)
          expect(Cart.abandoned.count).to eq(1)
          expect(Cart.abandoned.last).to eq(recent_abandoned_cart)
        end
      end

      context "when it's been less than 7 days" do
        it "do not remove carts" do
          travel_to(5.days.ago) do
            create_list(:cart, 5, status: :abandoned)
          end

          described_class.new.perform

          expect(Cart.abandoned.count).to eq(5)
        end
      end
    end
  end
end
