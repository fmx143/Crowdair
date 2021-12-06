class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  require 'uri'
  require 'net/http'

  def index
    @events = Event.all
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
    @user = current_user
    @event = Event.find(params[:id])
    @actions_held = @user.investments.find_by(event: @event).n_actions
    @actions_on_offer = @event.transactions.where(buyer_id: nil, seller_id: current_user.id).sum(:n_actions)
    @offers = @event.transactions.includes([:seller]).where(buyer_id: nil).order(price: :asc)
    @new_transaction = Transaction.new

    #REAL API

    # uri = URI("http://api.mediastack.com/v1/news")
    # params = {
    #   'access_key' => ENV["MEDIASTACK_ACCESS_KEY"],
    #   'search' => @event.title,
    #   'limit' => 6,
    #   'languages' => 'en'
    # }
    # uri.query = URI.encode_www_form(params)
    # response = Net::HTTP.get_response(uri)
    # news_json = response.read_body

    # TEMPORARY JSON
    news_json = File.read('app/assets/data/news.json')

    #---------------

    data_news = JSON.parse(news_json)
    @data = data_news["data"]
    # @news["data"][0]["title"] --> accéder au titre du Hash dans array dans Data

    @new_offer = Transaction.new

  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
