class CreateWsdls < ActiveRecord::Migration
  def self.up
    create_table :wsdls do |t|
      t.column :name, :string
      t.column :contents, :text
    end
  end

  def self.down
    drop_table :wsdls
  end
end
