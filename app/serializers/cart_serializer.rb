class CartSerializer < ActiveModel::Serializer
  attribute :id
  has_many :cart_items, key: :products, serializer: ProductSerializer

  attribute :total_price
end
