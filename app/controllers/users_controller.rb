class UsersController < ApplicationController
  def show
    @user = current_user
    # @all_events = Event.joins(:buyer_transactions).where(buyer_transactions: { user: @user })
    # @events = Event.joins().where(buyer_transactions.id_buyer = current_user)
    Event.joins(buyer_transactions: :current_user)
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)

    redirect_to(user_path)
  end

  def edit
    @user = User.find(params[:id])
  end
end
