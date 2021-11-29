class Transaction < ApplicationRecord
  after_save :add_to_investments

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :event

  def add_to_investments
    if buyer_id_changed?
      self.buyer.investments.find_by(event: self.event).n_actions += n_actions
      self.seller.investments.find_by(event: self.event).n_actions -= n_actions
      self.buyer.points -= price * n_actions
      self.seller.points += price * n_actions
    end
  end
end
