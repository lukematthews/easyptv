class CreateRunTimeExpresses < ActiveRecord::Migration[5.1]
  def change
    create_table :run_time_expresses do |t|
      t.references :run_time, foreign_key: true
      t.references :express, foreign_key: true

      t.timestamps
    end
  end
end
