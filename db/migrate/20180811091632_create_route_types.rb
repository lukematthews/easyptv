class CreateRouteTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :route_types do |t|
      t.integer :route_type
      t.string :route_type_name

      t.timestamps
    end
  end
end
