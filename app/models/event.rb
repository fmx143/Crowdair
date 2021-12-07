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
    transactions.where.not(buyer_id: nil).order(updated_at: :desc)
  end

  def offers
    transactions.where(buyer_id: nil).order(price: :asc)
  end

  def current_price
    concluded_transactions.last.price
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
  end
end
