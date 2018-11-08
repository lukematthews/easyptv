class CreateDepartures < ActiveRecord::Migration[5.1]
  def change
    create_table :departures do |t|
      t.integer :stop_api_id
      t.references :stop, foreign_key: true
      t.integer :route_api_id
      t.references :route, foreign_key: true
      t.integer :run_api_id
      t.references :run, foreign_key: true
      t.integer :direction_api_id
      t.references :direction, foreign_key: true
      t.string :scheduled_departure_utc
      t.string :estimated_departure_utc
      t.boolean :at_platform
      t.string :platform_number
      t.string :flags
      t.integer :departure_sequence

      t.timestamps
    end
  end
end
