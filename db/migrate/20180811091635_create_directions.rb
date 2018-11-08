class CreateDirections < ActiveRecord::Migration[5.1]
  def change
    create_table :directions do |t|
      t.integer :direction_id
      t.string :direction_name
      t.references :route, foreign_key: true
      t.integer :route_api_id
      t.references :route_type, foreign_key: true

      t.timestamps
    end
    add_index :directions, :direction_id
  end
end
