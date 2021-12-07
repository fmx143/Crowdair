class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def ranking
    @ranking = []
    User.all.where(admin: false).each do |user|
      @ranking << {
        username: user.username,
        pv: user.portfolio_history.last[1]
      }
    end
    @ranking.sort_by! { |elem| elem[:pv] }.reverse!
  end
end
