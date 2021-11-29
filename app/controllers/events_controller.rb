class EventsController < ApplicationController
  def index
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
    @event = Event.find(params[:id])
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
