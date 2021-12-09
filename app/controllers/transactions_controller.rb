class TransactionsController < ApplicationController
  # def new
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new
  # end

  def create
    event_show_method()
    @new_transaction = Transaction.new(create_transaction_params)
    @new_transaction.event = @event
    @new_transaction.seller = current_user
    @new_transaction.save ? redirect_to(event_path(@event)) : (render 'events/show')
    flash[:messages] = [] if flash[:messages].nil?
    flash[:messages] << {
      "title" => "Offer placed!",
      'content_start' => "You have put #{@new_transaction.n_actions} actions for a price of ",
      'content_end' => " coins on sale.",
      'strong' => @new_transaction.price,
      }
  end

  # def edit
  #   @transaction = Transaction.find(params[:id])
  # end


  def buy
    @offer = Transaction.find(params[:id])
    event_show_method()
    if buy_transaction_params[:n_actions].to_i < @offer.n_actions
      initial_n_actions = @offer.n_actions
      new_offer = @offer.dup
      @offer.update_attribute(:n_actions, buy_transaction_params[:n_actions].to_i)
      new_offer.update_attribute(:n_actions, (initial_n_actions - buy_transaction_params[:n_actions].to_i))
      @offer.update(buyer_id: current_user.id) ? redirect_to(event_path(@offer.event)) : (render 'events/show')
      User.update_all_portfolios(Time.now)
        flash[:messages] = [] if flash[:messages].nil?
        flash[:messages] << {
          "title" => "Actions bought!",
          'content_start' => "You have bought #{@offer.n_actions} actions for a total price of ",
          'content_end' => " coins.",
          'strong' => (@offer.n_actions *  @offer.price),
          }
    elsif buy_transaction_params[:n_actions].to_i > @offer.n_actions
      @offer.errors.add(:n_actions, "The seller is not selling more than #{@offer.n_actions}")
      render 'events/show'
    else
      @offer.update(buyer_id: current_user.id) ? redirect_to(event_path(@offer.event)) : (render 'events/show')
      User.update_all_portfolios(Time.now)
        flash[:messages] = [] if flash[:messages].nil?
        flash[:messages] << {
          "title" => "Actions bought!",
          'content_start' => "You have bought #{@offer.n_actions} actions for a total price of ",
          'content_end' => " coins.",
          'strong' => (@offer.n_actions *  @offer.price),
          }
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    redirect_to event_path(@transaction.event)
  end

  private

  def create_transaction_params
    params.require(:transaction).permit(:price, :n_actions)
  end

  def buy_transaction_params
    params.require(:transaction).permit(:n_actions)
  end

  def event_params
    params.require(:event).permit(:title, :description, :end_date)
  end

  def event_show_method
    @event = Event.find(params[:event_id])
    @offers = @event.transactions.includes([:seller]).where(buyer_id: nil).order(price: :asc)
    @new_transaction = Transaction.new
    @actions_held = current_user.investments.find_by(event: @event).n_actions
    @actions_on_offer = @event.transactions.where(buyer_id: nil, seller_id: current_user.id).sum(:n_actions)

    # @new_offer = Transaction.new
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
  end
end
