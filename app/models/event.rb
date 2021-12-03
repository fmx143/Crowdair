class EndDateValidator < ActiveModel::Validator
  def validate(record)
    unless record.end_date > Date.today
      record.errors.add :name, "Event end date must be in the future!"
    end
  end
end

class Event < ApplicationRecord
  after_save :add_initial_investment
  after_save :add_end_date_scheduler
  has_many :transactions
  has_many :investments

  include ActiveModel::Validations
  validates_with EndDateValidator # End date must be in the future!
  validates :title, presence: true, length: { in: 5..100 }
  validates :description, presence: true, length: { in: 10..300 }

  private

  def add_initial_investment
    User.all.each do |user|
      Investment.create!({
        user: user,
        event: self,
        n_actions: 10
      })

      ### This should be a Transaction with the 'bank' so that it is recorded
      ### in the user's history. Something like:
      # t = Transaction.create!(
      #   {
      #     price: 0.5,
      #     n_actions: 10,
      #     seller: User.find(user_id: 0), # The Bank
      #     event: self
      #   }
      # )
      # t.update(buyer_id: user.id)
    end
  end
<<<<<<< HEAD

  def add_end_date_scheduler
    HandleEventEndingJob.set(wait_until: end_date).perform_later(self)
  end
=======
>>>>>>> master
end
