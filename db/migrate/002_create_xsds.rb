class CreateXsds < ActiveRecord::Migration
  def self.up
    create_table :xsds do |t|
      t.column :name, :string
      t.column :contents, :text
    end
  end

  def self.down
    drop_table :xsds
  end
end
