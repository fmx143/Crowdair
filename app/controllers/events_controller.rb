class EventsController < ApplicationController
  def index
  end

  def new
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
      ["user = ? and event = ?", @user, @event]
    ).n_actions
    @offers = Transaction.where(
      ["buyer = ? and event = ?", nil, @event]
    ).order(:price).limit(5)
  end

  private

  def event_params
  end
end
