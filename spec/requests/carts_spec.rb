require 'rails_helper'

RSpec.describe "Carts", type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  describe 'POST /cart' do
    context 'add a new product to cart' do
      context 'when cart do not exist' do
        it 'creates a new cart and and save id in session' do
          product = create(:product)

          post cart_path, params: { product_id: product.id, quantity: 2 }

          expect(response).to have_http_status(:success)

          expect(response.parsed_body.deep_symbolize_keys).to include(
             :id, :total_price, :products => a_collection_containing_exactly(
              hash_including(:id, :name, :quantity, :unit_price, :total_price)
            )
          )
          expect(request.session[:cart_id]).to eq(Cart.last.id)
        end
      end

      context 'when cart already exist' do
        it 'update the current cart and add the product' do
          cart = create(:cart)
          product = create(:product)

          allow_any_instance_of(ActionDispatch::Request::Session)
            .to receive(:[]).with(:cart_id).and_return(cart.id)

          post cart_path, params: { product_id: product.id, quantity: 2 }

          expect(response).to have_http_status(:success)
          expect(Cart.count).to eq(1)
          expect(request.session[:cart_id]).to eq(cart.id)

          expect(response.parsed_body.deep_symbolize_keys).to include(
             :id, :total_price, :products => a_collection_containing_exactly(
              hash_including(:id, :name, :quantity, :unit_price, :total_price)
            )
          )
        end
      end

      context 'when product does not exist' do
        it 'return error message' do
          post cart_path, params: { product_id: 123, quantity: 2 }

          expect(response).to have_http_status(:not_found)
          expect(response.parsed_body.deep_symbolize_keys)
            .to eq({error: "Product not found."})
        end
      end
    end
  end

  describe "GET /cart" do
    context "list cart details" do
      it "successfully" do
        cart = create(:cart, total_price: 60.0)
        product = create(:product, name: "Product One", price: 10.0)
        product_2 = create(:product, name: "Product Two", price: 20.0)
        create(:cart_item, cart:, product:, quantity: 2, unit_price: 10.0, total_price: 20.0 )
        create(:cart_item, cart:, product: product_2, quantity: 2, unit_price: 20.0, total_price: 40.0 )

        allow_any_instance_of(ActionDispatch::Request::Session)
          .to receive(:[]).with(:cart_id).and_return(cart.id)

        get cart_path

        expected_response = {
          id: cart.id,
          total_price: "60.0",
          products: [
            {
              id: product.id,
              name: "Product One",
              quantity: 2,
              unit_price: "10.0",
              total_price: "20.0"
            },
            {
              id: product_2.id,
              name: "Product Two",
              quantity: 2,
              unit_price: "20.0",
              total_price: "40.0"
            }
          ]
        }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body.deep_symbolize_keys).to eq(expected_response)
      end
    end

    context "when there isn't a cart available" do
      it "return error" do
        get cart_path

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.deep_symbolize_keys)
          .to eq({error: "Cart not found."})
      end
    end
  end

  describe "POST /cart/add_item" do
    context 'when the product already is in the cart' do
      let(:product) { create(:product, name: "Test Product", price: 10.0) }
      let(:cart) { create(:cart) }
      let!(:cart_item) { create(:cart_item, cart:, product:) }

      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        allow_any_instance_of(ActionDispatch::Request::Session)
          .to receive(:[]).with(:cart_id).and_return(cart.id)

        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context "when product does not exist" do
      it 'return error message' do
        cart = create(:cart)

        allow_any_instance_of(ActionDispatch::Request::Session)
          .to receive(:[]).with(:cart_id).and_return(cart.id)

        post add_item_cart_path, params: { product_id: 123, quantity: 2 }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.deep_symbolize_keys)
          .to eq({error: "Product not found."})
      end
    end

    context "when there isn't a cart available" do
      it "return error" do
        product = create(:product)

        post add_item_cart_path, params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.deep_symbolize_keys)
          .to eq({error: "Cart not found."})
      end
    end
  end
end
