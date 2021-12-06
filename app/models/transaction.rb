class Transaction < ApplicationRecord
  before_update :add_to_investments

  belongs_to :buyer, class_name: 'User', optional: true
  belongs_to :seller, class_name: 'User'
  belongs_to :event
  validates :price, numericality: { in: 1..100 } #TO CHECK
  validate :actions_validator
  validate :points_validator

  private

  def add_to_investments
    if buyer_id_changed?
      buyer_invest_actions = buyer.investments.find_by(event: event)
      seller_invest_actions = seller.investments.find_by(event: event)
      buyer_invest_actions.update(n_actions: buyer_invest_actions.n_actions + n_actions)
      seller_invest_actions.update(n_actions: seller_invest_actions.n_actions - n_actions)
      buyer.update(points: buyer.points - (price * n_actions))
      seller.update(points: seller.points + (price * n_actions))
    end
  end

  def points_validator
    if buyer_id_changed?
      if buyer.points < (price * n_actions)
        errors.add(:n_actions, "You don't have enough points")
      end
    end
  end

  def actions_validator
    unless buyer_id_changed?
      seller_actions = seller.investments.find_by(event: event).n_actions
      actions_on_offer = event.transactions.where(buyer_id: nil, seller_id: seller.id).sum(:n_actions)
      if seller_actions - actions_on_offer < n_actions
        errors.add(:n_actions, "You don't have enough actions, or change your previous offers")
      end
    end
  end
end
