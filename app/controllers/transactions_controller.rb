class TransactionsController < ApplicationController
  # def new
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new
  # end

  def create
    event_show_method()
    @transaction = Transaction.new(create_transaction_params)
    @transaction.event = @event
    @transaction.seller = current_user
    @transaction.save ? redirect_to(event_path(@event)) : (render 'events/show')
  end

  # def edit
  #   @transaction = Transaction.find(params[:id])
  # end


  def buy
    @initial_transaction = Transaction.find(params[:id])
    if buy_transaction_params[:n_actions].to_i < @initial_transaction.n_actions
      initial_n_actions = @initial_transaction.n_actions
      new_transaction = @initial_transaction.dup
      @initial_transaction.update_attribute(:n_actions, buy_transaction_params[:n_actions].to_i)
      new_transaction.update_attribute(:n_actions, (initial_n_actions - buy_transaction_params[:n_actions].to_i))
    elsif buy_transaction_params[:n_actions].to_i > @initial_transaction.n_actions
      @initial_transaction.errors.add(:n_actions, "The seller is not selling more than #{@initial_transaction.n_actions}")
    end
    event_show_method()
    @initial_transaction.update(buyer_id: current_user.id) ? redirect_to(event_path(@initial_transaction.event)) : (render 'events/show')
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
    @user = current_user
    @actions_held = @user.investments.find_by(event: @event).n_actions
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
