class AddImgUrlToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :img_url, :string
  end
end
