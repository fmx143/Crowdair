class AddArchivedToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :archived, :boolean, null: false, default: false
  end
end
