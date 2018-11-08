class CreateStops < ActiveRecord::Migration[5.1]
  def change
    create_table :stops do |t|
      t.integer :stop_id
      t.string :stop_name
      t.integer :route_type_api_id
      t.references :route_type, foreign_key: true
      t.references :route, foreign_key: true
      t.string :stop_suburb
      t.string :stop_suburb
      t.string :station_type
      t.string :station_description

      t.timestamps
    end
    add_index :stops, :stop_id
  end
end
