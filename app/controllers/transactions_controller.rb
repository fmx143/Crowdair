class TransactionsController < ApplicationController
  def new
  end

  def create
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
  end

  private

  def transaction_params
    params.require(:transaction).permit(:buyer_id, :seller_id, :price, :n_actions)
  end
end
