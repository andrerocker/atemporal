class AddCallbackServerToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :callback_server, :string
  end
end
