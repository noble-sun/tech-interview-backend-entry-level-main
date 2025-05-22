FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
    unit_price { 10.0 }
    total_price { 10.0 }
  end
end
