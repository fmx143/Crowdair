class UsersController < ApplicationController
  def show
    @user = current_user
    Event.joins(buyer_transactions: :current_user)
    @investments = Investment.all.where(user_id: current_user.id)
    @transactions = current_user.transactions.where.not(buyer_id: nil).order(updated_at: :desc).limit(10)
    @offers = current_user.transactions.where(buyer_id: nil)
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
