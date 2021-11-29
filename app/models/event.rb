class Event < ApplicationRecord
  after_save :add_initial_investment
  has_many :transactions
  has_many :investments

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
