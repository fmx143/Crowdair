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

  private

  def add_initial_investment
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
