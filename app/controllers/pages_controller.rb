class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def ranking
    @users = User.order(points: :desc)

    #@users_points = User.all(points)
    # @user_up = User.first(3).where(User.points >= current_user.points)
    # @user_down = User.first(3).where(User.points <= current_user.points)
  end
end
