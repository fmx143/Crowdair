class User < ApplicationRecord
  after_create :add_initial_portfolio
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_id'
  has_many :investments
  has_many :portfolios, dependent: :destroy

  validates :username, presence: true, length: { maximum: 50 }

  def transactions
    buyer_transactions.or(seller_transactions)
  end

  def engaged_investments
    engaged_investments = []
    investments.each do |investment|
      n = transactions.where(event_id: investment.event.id).count
      engaged_investments.push(investment) unless n.zero? || investment.event.archived
    end
    engaged_investments
  end

  def offers
    transactions.where(buyer_id: nil)
  end

  def latest_transactions
    transactions.where.not(buyer_id: nil).order(updated_at: :desc)
  end

  def self.update_all_portfolios
    User.all.each do |user|
      Portfolio.create!(
        user: user,
        pv: user.compute_portfolio_value
      )
    end
  end

  def self.user_ranking
    ranking = []
    User.all.where(admin: false).each do |user|
      ranking << {
        username: user.username,
        pv: user.portfolio_history.last[1],
        email: user.email
      }
    end
    ranking.sort_by! { |elem| elem[:pv] }.reverse!
  end

  def portfolio_history
    Portfolio.where(user_id: id).order(created_at: :asc).pluck(:created_at, :pv)
  end

  def compute_portfolio_value
    portfolio_value = points
    investments.each do |i|
      portfolio_value += i.n_actions * i.event.current_price
    end
    portfolio_value
  end

  def ranking_position
    ranking = User.user_ranking
    ranking.find_index { |r| r[:email] == email } + 1
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
    bank = User.find_by(email: 'crowdair@gmail.com')
    Event.all.each do |event|
      Investment.create!(
        user: self,
        event: event,
        n_actions: 0
      )
      t = Transaction.create!(
        seller_id: bank.id,
        price: 0,
        n_actions: 10,
        event: event
      )
      t.update(buyer_id: id)
    end
    User.update_all_portfolios
  end
end
