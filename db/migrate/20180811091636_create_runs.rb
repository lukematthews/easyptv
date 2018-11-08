class CreateRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :runs do |t|
      t.integer :run_id
      t.integer :route_api_id
      t.integer :route_type_api
      t.integer :final_stop_id
      t.string :destination_name
      t.string :status
      t.integer :direction_api_id
      t.integer :run_sequence
      t.integer :express_stop_count
      t.references :route, foreign_key: true
      t.references :route_type, foreign_key: true
      t.references :direction, foreign_key: true

      t.timestamps
    end
  end
end
