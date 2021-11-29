class Transaction < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :event

  validates :price, numericality: { in: 0..1 }
end
