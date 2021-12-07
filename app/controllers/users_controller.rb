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
    @engaged_investments = @user.engaged_investments
    @transactions = current_user.latest_transactions
    @day = @transactions.first.updated_at.day if @transactions.length >= 1
    @offers = current_user.offers
    @ranking_position = @user.ranking_position
    @total_participants = User.count
    @points_history = @user.points_history
    @portfolio_values = @user.portfolio_history
    @portfolio_values_1h = @user.portfolio_history_1h
  end

  def edit
    @user = current_user
  end
end
