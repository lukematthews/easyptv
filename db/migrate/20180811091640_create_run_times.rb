class CreateRunTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :run_times do |t|
      t.references :run_day, foreign_key: true
      t.integer :hour
      t.integer :minutes

      t.timestamps
    end
  end
end
