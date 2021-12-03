class UsersController < ApplicationController
  def show
    @user = current_user
    Event.joins(buyer_transactions: :current_user)
    @investments = @user.investments
    @engaged_investments = []
    @investments.each do |investment|
      n = @user.transactions.where(event_id: investment.event.id).count
      @engaged_investments.push(investment) if n > 1
    end

    @transactions = current_user.transactions.where.not(buyer_id: nil).order(updated_at: :desc)
    @latest_transactions = @transactions.limit(12)
    @day = @latest_transactions.first.updated_at.day if @latest_transactions.length >= 1

    @offers = current_user.transactions.where(buyer_id: nil)
    @total_participants = User.count
    @ranking_position = User.order(points: :desc).pluck(:id).find_index(@user.id) + 1

    # Compute data for portfolio graph in dashboard /!\ Not accurate! /!\
    balance = @user.points
    @points_history = {}
    @points_history[Time.now] = balance
    @transactions.each do |transaction|
      @points_history[transaction.updated_at] = balance
      factor = transaction.buyer == @user ? -1 : 1 # subtract if buying, add if selling
      balance += transaction.n_actions * transaction.price * factor
    end
    # raise
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
