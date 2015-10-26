class AddDnsAndIpToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :dns, :string
    add_column :instances, :ip, :string
  end
end
