class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :image
      t.datetime :time
      t.text :payload
      t.string :state

      t.timestamps
    end
  end
end
