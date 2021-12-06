class UsersController < ApplicationController
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
    @portfolio_values = @user.portfolio_values
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)

    redirect_to(user_path)
  end

  def edit
    @user = current_user
  end
end
