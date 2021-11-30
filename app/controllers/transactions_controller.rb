class TransactionsController < ApplicationController
  def new
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(create_transaction_params)
    @event = Event.find(params[:event_id])
    @transaction.event = @event
    @transaction.seller = current_user
    @transaction.save ? (redirect_to event_path(@event)) : (render :new)
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def update
    @initial_transaction = Transaction.find(params[:id])
    if buy_transaction_params[:n_actions].to_i < @initial_transaction.n_actions
      @new_transaction = @initial_transaction.dup
      @new_transaction.update(n_actions: (@initial_transaction.n_actions - buy_transaction_params[:n_actions].to_i))
      @initial_transaction.update(n_actions: buy_transaction_params[:n_actions].to_i)
    end
    @initial_transaction.update(buyer_id: current_user.id)
    redirect_to event_path(@initial_transaction.event)
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
  end

  private

  def create_transaction_params
    params.require(:transaction).permit(:price, :n_actions)
  end

def buy_transaction_params
    params.require(:transaction).permit(:n_actions)
  end
end
