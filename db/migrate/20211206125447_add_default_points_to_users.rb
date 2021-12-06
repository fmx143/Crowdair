class AddDefaultPointsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:users, :points, 1000)
  end
end
