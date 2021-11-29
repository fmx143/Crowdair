class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :buyer, null: false
      t.references :seller, null: false
      t.float :price
      t.integer :n_actions
      t.timestamps
    end
    add_foreign_key :transactions, :users, column: :buyer_id
    add_foreign_key :transactions, :users, column: :seller_id
  end
end
