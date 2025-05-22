class ProductSerializer < ActiveModel::Serializer
  attribute(:id) {object.product.id}
  attribute(:name) {object.product.name}
  attribute :quantity
  attribute :unit_price
  attribute :total_price
end
