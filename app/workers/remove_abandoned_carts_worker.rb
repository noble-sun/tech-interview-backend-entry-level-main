class RemoveAbandonedCartsWorker
  include Sidekiq::Job

  def perform
    Cart.abandoned.where("updated_at < ?", 7.days.ago).destroy_all
  end
end
