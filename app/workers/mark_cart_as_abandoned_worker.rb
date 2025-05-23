class MarkCartAsAbandonedWorker
  include Sidekiq::Job

  def perform
    Cart.active.find_each(&:mark_as_abandoned)
  end
end
