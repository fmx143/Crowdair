class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
    @user = current_user
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    @transaction.save ? (redirect_to event_path(@event)) : (render :new)
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update(event_params)
    redirect_to event_path(@event)
  end

  def show
    @user = current_user
    @event = Event.find(params[:id])
    @actions_held = @user.investments.find_by(event: @event).n_actions
    @offers = @event.transactions.where(buyer_id: nil).order(price: :asc)
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
