class CartsController < ApplicationController
  rescue_from ProductNotFoundError, with: :render_product_not_found
  rescue_from CartNotFoundError, with: :render_cart_not_found

  def create
    cart = Cart.find_or_create_by!(id: session[:cart_id])

    AddOrUpdateCartItemService.call(
      cart:,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    session[:cart_id] = cart.id

    render json: cart.reload, serializer: CartSerializer, status: :ok
  end

  def show
    render json: current_cart, serializer: CartSerializer, status: :ok
  end

  def add_item
    AddOrUpdateCartItemService.call(
      cart: current_cart,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    render json: current_cart.reload, serializer: CartSerializer, status: :ok
  end

  def remove_item
    RemoveItemFromCartService.call(
      cart: current_cart,
      product_id: cart_params[:product_id]
    )

    render json: current_cart, serializer: CartSerializer, status: :ok
  rescue ProductNotInCartError
    render json: { error: I18n.t('errors.product_not_in_cart') }, status: :unprocessable_entity
  end

  private

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id]) || raise(CartNotFoundError)
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def render_product_not_found
    render json: { error: I18n.t('errors.product_not_found') }, status: :not_found
  end

  def render_cart_not_found
    render json: { error: I18n.t('errors.cart_not_found') }, status: :not_found
  end
end
