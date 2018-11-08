class CreateStopOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :stop_orders do |t|
      t.references :route, foreign_key: true
      t.references :direction, foreign_key: true
      t.references :stop, foreign_key: true
      t.integer :order

      t.timestamps
    end
  end
end
