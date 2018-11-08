class AddMapUrlToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :map_url, :string
  end
end
