class AddNotifiedToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :notified, :boolean
  end
end
