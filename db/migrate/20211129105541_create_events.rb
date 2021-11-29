class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.datetime :end_date
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
