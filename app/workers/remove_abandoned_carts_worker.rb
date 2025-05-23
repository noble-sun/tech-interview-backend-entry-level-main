class RemoveAbandonedCartsWorker
  include Sidekiq::Job

  def perform
    Cart.abandoned.find_each(&:remove_if_abandoned)
  end
end
