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
    @transaction.save ? (redirect_to user_path(@transaction.user_id)) : (render :new)
  end

  def edit
    @transaction = Transaction.find(params[:id])
    @event = @transaction.event
    @user = current_user
  end

  def update
    @transaction = Transaction.find(params[:id])
    @transaction.update(transaction_params)
    redirect_to(user_path(@transaction.user))
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
