class EndDateValidator < ActiveModel::Validator
  def validate(record)
    unless record.end_date > Date.today
      record.errors.add :name, "Event end date must be in the future!"
    end
  end
end

class Event < ApplicationRecord
  after_create :add_initial_investment
  has_many :transactions
  has_many :investments

  include ActiveModel::Validations
  validates_with EndDateValidator # End date must be in the future!
  validates :title, presence: true, length: { in: 5..100 }
  validates :description, presence: true, length: { in: 10..300 }

  def pay_due(outcome)
    # Called when event ends (when admin presses yes/no in events index)
    end_action_price = outcome == "yes" ? 100 : 0
    bank = User.find_by(email: 'crowdair@gmail.com')
    offers.destroy_all
    User.all.each do |user|
      actions_held = user.investments.where(event_id: id).first.n_actions
      t = Transaction.create!(
        seller_id: user.id,
        price: end_action_price,
        n_actions: actions_held,
        event_id: id
      )
      t.update(buyer_id: bank.id)
    end
    User.update_all_portfolios
  end

  def last_hour_change
    p0 = 0
    p1 = 0
    if concluded_transactions.count.positive?
      recent_transactions = concluded_transactions.where("updated_at >= ?", 1.hour.ago)
      if recent_transactions.count.positive?
        p0 = recent_transactions.last.price
        p1 = recent_transactions.first.price
      end
    end
    p1 - p0
  end

  def concluded_transactions
    transactions.where.not(buyer_id: nil).order(updated_at: :asc)
  end

  def offers
    transactions.where(buyer_id: nil).order(price: :asc)
  end

  def current_price
    concluded_transactions.empty? || concluded_transactions.last.price.zero? ? 50 : concluded_transactions.last.price
  end

  private

  def add_initial_investment
    bank = User.find_by(email: 'crowdair@gmail.com')
    User.all.each do |user|
      Investment.create!(
        user: user,
        event: self,
        n_actions: 0
      )
      t = Transaction.create!(  # Note: requires investment to exist (created above with 0 actions)
        seller_id: bank.id,
        price: 0,
        n_actions: 10,
        event: self
      )
      t.update(buyer_id: user.id, updated_at: 1.day.ago)
    end
    User.update_all_portfolios
  end
end
