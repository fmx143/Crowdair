class ChangePointsToBeIntegerInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :points, :integer
  end
end
