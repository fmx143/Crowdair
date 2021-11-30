class TransactionsController < ApplicationController
  def new
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @event = Event.find(params[:event_id])
    @transaction.event = @event
    @transaction.seller = current_user
    @transaction.save ? (redirect_to event_path(@event)) : (render :new)
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def update
    @transaction = Transaction.find(params[:id])
    @transaction.update(buyer_id: current_user.id)
    redirect_to event_path(@transaction.event)
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
  end

  private

  def transaction_params
    params.require(:transaction).permit(:price, :n_actions)
  end
end
