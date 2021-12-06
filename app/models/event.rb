class EndDateValidator < ActiveModel::Validator
  def validate(record)
    unless record.end_date > Date.today
      record.errors.add :name, "Event end date must be in the future!"
    end
  end
end

class Event < ApplicationRecord
  after_save :add_initial_investment
  has_many :transactions
  has_many :investments

  include ActiveModel::Validations
  validates_with EndDateValidator # End date must be in the future!
  validates :title, presence: true, length: { in: 5..100 }
  validates :description, presence: true, length: { in: 10..300 }

  def pay_due(outcome)
    # Called when event ends (when admin presses yes/no in events index)
    end_action_price = outcome == "yes" ? 1.0 : 0.0
    bank = User.find_by(email: 'crowdair@gmail.com')
    User.all.each do |user|
      actions_held = user.investments.where(event_id: id).n_actions
      Transaction.create!(
        buyer_id: bank.id,
        seller_id: user.id,
        price: end_action_price,
        n_actions: actions_held,
        event_id: id
      )
    end
  end

  private

  def add_initial_investment
    User.all.each do |user|
      Investment.create!({
        user: user,
        event: self,
        n_actions: 10
      })
    end
  end
end
