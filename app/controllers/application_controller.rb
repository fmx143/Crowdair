class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  add_flash_types :event
  after_action :check_notifications
  add_flash_types :messages
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    attributes = [:username, :email, :avatar, :password]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end

   def check_notifications
    if user_signed_in?
      not_notified_transactions = current_user.seller_transactions.where.not(buyer_id: nil).where(notified: nil).order(updated_at: :desc)
      unless not_notified_transactions.empty?
        flash[:messages] = [] if flash[:messages].nil?
        not_notified_transactions.each do |transaction|
          if transaction.buyer == User.find_by(email: 'crowdair@gmail.com')
            flash[:messages] << {
              'title'=> "Event ##{transaction.event.id} ended !",
              'content_start'=> "The Bank has bought #{transaction.n_actions} actions for a total of ",
              'content_end'=> " coins.",
              'strong'=> (transaction.n_actions *  transaction.price),
              'url'=> event_path(transaction.event),
              'time'=> transaction.updated_at.strftime("%H:%M")
              }
          else
            flash[:messages] << {
              'title'=> "Action sold ! - Event ##{transaction.event.id}",
              'content_start'=> "#{transaction.buyer.username} has bought #{transaction.n_actions} actions for a total of ",
              'content_end'=> " coins.",
              'strong'=> (transaction.n_actions *  transaction.price),
              'url'=> event_path(transaction.event),
              'time'=> transaction.updated_at.strftime("%H:%M")
              }
          end
          transaction.update_attribute(:notified, true)
        end
      end
    end
  end
end
