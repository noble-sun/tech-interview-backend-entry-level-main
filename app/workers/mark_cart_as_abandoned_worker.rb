class MarkCartAsAbandonedWorker
  include Sidekiq::Job

  def perform
    Cart.active.where("updated_at < ?", 3.hours.ago).update_all(status: :abandoned)
  end
end
