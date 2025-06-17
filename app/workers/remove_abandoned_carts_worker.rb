class RemoveAbandonedCartsWorker
  include Sidekiq::Job

  def perform
    Cart.abandoned.find_each(batch_size: 500) {|cart| cart.remove_if_abandoned }
  end
end
