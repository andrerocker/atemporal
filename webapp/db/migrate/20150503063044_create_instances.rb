class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :aws_id
      t.references :job

      t.timestamps null: false
    end
  end
end
