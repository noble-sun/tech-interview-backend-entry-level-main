FactoryBot.define do
  factory :cart do
    total_price { 0.0 } 
    status { 'active' }
    last_interaction_at { DateTime.now }

    factory :shopping_cart, class: 'Cart'
  end
end
