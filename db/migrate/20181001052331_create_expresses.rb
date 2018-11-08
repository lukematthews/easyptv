class CreateExpresses < ActiveRecord::Migration[5.1]
  def change
    create_table :expresses do |t|
      t.string :abbreviation
      t.string :description
      t.references :start_stop, foreign_key: {to_table: :stops}
      t.references :end_stop, foreign_key: {to_table: :stops}
      t.references :route, foreign_key: true
      t.references :direction, foreign_key: true

      t.timestamps
    end
  end
end
