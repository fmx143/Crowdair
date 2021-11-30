class UsersController < ApplicationController
  def show
    @user = current_user
    Event.joins(buyer_transactions: :current_user)

    @investments = Investment.all.where(user_id: current_user.id)
    # obtenir le nombre d'actions spécifique à un investement
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
