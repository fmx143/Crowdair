class EventsController < ApplicationController
  require 'uri'
  require 'net/http'
  require 'openssl'

  def index
    @events = Event.all
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
    @offers = @event.transactions.where(buyer_id: nil).order(price: :asc)

    url = URI("https://google-news.p.rapidapi.com/v1/top_headlines?lang=en&country=US")
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'google-news.p.rapidapi.com'
    request["x-rapidapi-key"] = '5d8e5d60aemsh5ede1e83832d521p1a3615jsn0f0668644bc2'
    response = http.request(request)
    puts response.read_body
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end
end
