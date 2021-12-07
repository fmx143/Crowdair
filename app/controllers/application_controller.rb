class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  add_flash_types :event
  after_action :check_notifications

  def check_notifications
    if user_signed_in?
      not_notified_transactions = current_user.seller_transactions.where.not(buyer_id: nil).where(notified: nil).order(updated_at: :desc)
      unless not_notified_transactions.nil?
        not_notified_transactions.each do |transaction|
          flash[:event] = "#{transaction.buyer.username} bought from you: #{transaction.n_actions} actions of the event \"#{transaction.event.title}\""
          transaction.update_attribute(:notified, true)
        end
      end
    end
  end
end
