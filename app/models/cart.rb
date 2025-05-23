class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  validates_presence_of :status, :total_price
  validates :last_interaction_at, presence: true, unless: :new_record?
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  enum :status, { active: 'active', abandoned: 'abandoned' }

  def add_or_update_cart_item(product:, quantity:)
    item = cart_items.find_or_initialize_by(product_id: product.id)
    quantity += item.quantity if item.persisted?
    item.update!(quantity:, unit_price: product.price)

    recalculate_total_price!
  end

  def recalculate_total_price!
    self.total_price = cart_items.sum(:total_price)
    self.last_interaction_at = DateTime.now 
    save!
  end

  def mark_as_abandoned
    abandoned! if last_interaction_at < 3.hours.ago
  end

  def remove_if_abandoned
    destroy! if abandoned? && last_interaction_at < 7.days.ago
  end
end
