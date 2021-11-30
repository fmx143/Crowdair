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
    @actions_held = @user.investments.find_by(event: @event).n_actions
    @offers = @event.transactions.where(buyer_id: nil)
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
