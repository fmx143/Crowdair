class UsersController < ApplicationController
  def new
    @user = User.new(user_params)
  end

  def create
    @user = current_user
  end

  def show
    @user = current_user
    Event.joins(buyer_transactions: :current_user)
    @engaged_investments = select_engaged_investments
    @transactions = current_user.transactions.where.not(buyer_id: nil).order(updated_at: :desc)
    @day = @transactions.first.updated_at.day if @transactions.length >= 1
    @offers = current_user.transactions.where(buyer_id: nil)
    @ranking_position = User.order(points: :desc).pluck(:id).find_index(@user.id) + 1
    @total_participants = User.count
    @points_history = compute_points_history
  end

  # def update
  #   @user = User.find(params[:id])
  #   @user.update(user_params)
  #   @user.save
  #   raise
  #   redirect_to(user_path(:id))
  # end

  # def edit
  #   @user = current_user
  #   @user.update(user_params)
  #   @user.save
  #   raise
  #   redirect_to(user_path)
  # end

  private

  def select_engaged_investments  # Investments with at least 2 transactions
    engaged_investments = []
    @user.investments.each do |investment|
      n = @user.transactions.where(event_id: investment.event.id).count
      engaged_investments.push(investment) if n > 1
    end
    engaged_investments
  end

  def compute_points_history
    balance = @user.points
    points_history = {}
    points_history[Time.now] = balance
    @transactions.each do |transaction|
      points_history[transaction.updated_at] = balance
      factor = transaction.buyer == @user ? 1 : -1 # subtract if buying, add if selling
      balance += transaction.n_actions * transaction.price * factor
    end
    points_history
  end
end
