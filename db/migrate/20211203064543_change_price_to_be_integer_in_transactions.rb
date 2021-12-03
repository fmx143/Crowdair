class ChangePriceToBeIntegerInTransactions < ActiveRecord::Migration[6.1]
  def change
    change_column :transactions, :price, :integer
  end
end
