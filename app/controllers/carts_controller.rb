class CartsController < ApplicationController
  ## TODO Escreva a lógica dos carrinhos aqui

  def create
    cart = Cart.find_or_create_by!(id: session[:cart_id])

    result = AddProductToCartService.call(
      cart:,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    session[:cart_id] = cart.id if result

    render json: cart, serializer: CartSerializer, status: :ok
  rescue ProductNotFoundError
    render json: { error: "Product does not exist." }, status: :not_found
  end

  def show
    cart = Cart.find(session[:cart_id])

    render json: cart, serializer: CartSerializer, status: :ok
  rescue
    render json: { error: "Cart not found." }, status: :not_found
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end
end
