class User < ApplicationRecord
  after_save :add_initial_portfolio
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_id'
  has_many :investments

  # validates :username, length: { in: 3..60 }

  def transactions
    buyer_transactions + seller_transactions
  end

  def add_initial_portfolio
    Event.all.each do |event|
      Investment.create!({
        user: self,
        event: event,
        n_actions: 10
      })
    end
  end
end
