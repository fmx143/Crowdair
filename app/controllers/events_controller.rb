class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
    @user = current_user
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @user = current_user
    @event = Event.find(params[:id])
    @actions_held = Investment.where(
      ["user_id = ? and event_id = ?", @user.id, @event.id]
    ).first.n_actions
    @offers = Transaction.where(
      ["buyer_id = ? and event_id = ?", nil, @event.id]
    ).order(:price).limit(5)
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
