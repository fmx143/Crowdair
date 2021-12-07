class CreatePortfolios < ActiveRecord::Migration[6.1]
  def change
    create_table :portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.float :pv

      t.timestamps
    end
  end
end
