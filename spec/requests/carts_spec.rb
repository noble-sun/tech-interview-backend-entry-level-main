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

          parsed_response = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_response).to include(
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

          parsed_response = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_response).to include(
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
          expect(JSON.parse(response.body, symbolize_names: true))
            .to eq({error: "Product does not exist."})
        end
      end
    end
  end

  describe "POST /add_items" do
    context 'when the product already is in the cart' do
      let(:product) { create(:product, name: "Test Product", price: 10.0) }

      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        cart = create(:cart)
        cart_item = create(:cart_item, cart:, product:)

        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
