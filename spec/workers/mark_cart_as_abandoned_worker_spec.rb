require "rails_helper"

RSpec.describe MarkCartAsAbandonedWorker, type: :worker do
  it 'enqueues job' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
  end

  describe "#perform" do
    context "when there are active carts that were not used for more than 3 hours" do
      it "change status of carts to abandoned" do
        travel_to(4.hours.ago) do
          create_list(:cart, 5)
        end

        recent_cart = create(:cart, status: :active)

        described_class.new.perform

        expect(Cart.abandoned.count).to eq(5)
        expect(recent_cart.reload.active?).to be_truthy
      end
    end

    context "when there aren't any cart there were not used for more than 3 hours" do
      it "does not change status to abandoned" do
        travel_to(2.hours.ago) do
          create_list(:cart, 5)
        end

        described_class.new.perform

        expect(Cart.abandoned.count).to eq(0)
      end
    end
  end
end
