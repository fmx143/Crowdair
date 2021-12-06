class User < ApplicationRecord
  after_create :add_initial_portfolio
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_id'
  has_many :investments

  has_many :portfolios, dependent: :destroy

  # validates :username, length: { in: 3..60 }

  def transactions
    buyer_transactions.or(seller_transactions)
  end

  def engaged_investments
    engaged_investments = []
    investments.each do |investment|
      n = transactions.where(event_id: investment.event.id).count
      engaged_investments.push(investment) if n > 1
    end
    engaged_investments
  end

  def offers
    transactions.where(buyer_id: nil)
  end

  def latest_transactions
    transactions.where.not(buyer_id: nil).order(updated_at: :desc)
  end

  def portfolio_history
    Portfolio.where(user_id: id).order(created_at: :desc).pluck(:created_at, :pv)
  end

  def compute_portfolio_value
    portfolio_value = points
    investments.each do |investment|
      event_history = investment.event.concluded_transactions
      current_value = event_history.count.positive? ? investment.event.current_price : 50
      portfolio_value += investment.n_actions * current_value
    end
    portfolio_value
  end

  def ranking_position
    User.order(points: :desc).pluck(:id).find_index(id) + 1
  end

  def points_history
    balance = points
    points_history = {}
    points_history[Time.now] = balance
    latest_transactions.each do |transaction|
      points_history[transaction.updated_at] = balance
      factor = transaction.buyer == @user ? 1 : -1 # subtract if buying, add if selling
      balance += transaction.n_actions * transaction.price * factor
    end
    points_history
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
