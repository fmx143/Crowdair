class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def ranking
    @ranking = User.user_ranking
  end
end
