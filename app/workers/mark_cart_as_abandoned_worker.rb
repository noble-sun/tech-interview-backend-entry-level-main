class MarkCartAsAbandonedWorker
  include Sidekiq::Job

  def perform
    Cart.active.find_each(batch_size: 500) {|cart| cart.mark_as_abandoned }
  end
end
