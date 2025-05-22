class CartsController < ApplicationController
  ## TODO Escreva a lógica dos carrinhos aqui
  rescue_from ProductNotFoundError, with: :render_product_not_found
  rescue_from CartNotFoundError, with: :render_cart_not_found

  def create
    cart = Cart.find_or_create_by!(id: session[:cart_id])

    result = AddOrUpdateCartItemService.call(
      cart:,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    session[:cart_id] = cart.id if result

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def show
    cart = Cart.find_by(id: session[:cart_id])
    raise CartNotFoundError unless cart

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def add_item
    cart = Cart.find_by(id: session[:cart_id])
    raise CartNotFoundError unless cart

    result = AddOrUpdateCartItemService.call(
      cart:,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    render json: cart, serializer: CartSerializer, status: :ok
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def render_product_not_found
    render json: { error: "Product not found." }, status: :not_found
  end

  def render_cart_not_found
    render json: { error: "Cart not found." }, status: :not_found
  end
end
