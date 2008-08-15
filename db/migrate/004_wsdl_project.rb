class WsdlProject < ActiveRecord::Migration
  def self.up
    add_column :wsdls, :host, :string
    add_column :wsdls, :application, :string
  end

  def self.down
  end
end
