class Investment < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :n_actions, numericality: { greater_than_or_equal_to: 0 }
end
