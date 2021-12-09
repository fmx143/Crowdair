class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  require 'uri'
  require 'net/http'

  def index
    @events = Event.all.where(archived: false)
    # @past_events = Event.where("end_date < ?", Time.now)    # Event.all.where(Date.today = Event.end_date)
    # @events[1].end_date
  end

  def new
    @event = Event.new
    @user = current_user
  end

  def create
    @event = Event.new(event_params)
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
    @event = Event.find(params[:id])
    @actions_held = current_user.investments.find_by(event: @event).n_actions
    @actions_on_offer = @event.transactions.where(buyer_id: nil, seller_id: current_user.id).sum(:n_actions)
    @offers = @event.transactions.includes([:seller]).where(buyer_id: nil).order(price: :asc)
    @new_transaction = Transaction.new
    bank = User.find_by(email: 'crowdair@gmail.com')
    @price_history = @event.transactions.where.not(buyer_id: nil).where.not(seller_id: bank.id).pluck(:updated_at, :price)

    @t = Time.new(0)
    @countdown_time_in_seconds = 100 # change this value
    
    @news = @event.news
  end
  
  def archive
    @event = Event.find(params[:id])
    @event.pay_due(params["outcome"])
    @event.archived = true
    @event.save
    redirect_to(events_path)
  end

  def show
    @event = Event.find(params[:id])
    @actions_held = current_user.investments.find_by(event: @event).n_actions
    @actions_on_offer = @event.transactions.where(buyer_id: nil, seller_id: current_user.id).sum(:n_actions)
    @offers = @event.transactions.includes([:seller]).where(buyer_id: nil).order(price: :asc)
    @new_transaction = Transaction.new
    @news = @event.news
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
