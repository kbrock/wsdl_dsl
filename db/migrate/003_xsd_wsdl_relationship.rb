class XsdWsdlRelationship < ActiveRecord::Migration
  def self.up
    create_table :wsdls_xsds, :id=>false do |t|
        t.column 'xsd_id',:integer
        t.column 'wsdl_id',:integer
    end
  end

  def self.down
    drop_table :wsdls_xsds
  end
end
