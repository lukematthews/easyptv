class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.references :route_type, foreign_key: true
      t.integer :route_type_api_id
      t.integer :route_id
      t.string :route_name
      t.string :route_number
      t.string :route_gtfs_id

      t.timestamps
    end
  end
end
