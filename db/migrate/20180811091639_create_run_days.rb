class CreateRunDays < ActiveRecord::Migration[5.1]
  def change
    create_table :run_days do |t|
      t.references :route, foreign_key: true
      t.references :stop, foreign_key: true
      t.references :direction, foreign_key: true
      t.string :day_name

      t.timestamps
    end
  end
end
