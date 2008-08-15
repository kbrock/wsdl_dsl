require File.dirname(__FILE__) + '/../wsdlgen.rb'

describe SimpleTypeDef do
  describe "(direct)" do
    before(:each) do
      @field=SimpleTypeDef.new 'integer'
    end
  
    it "should return java name when send #java_name" do
      @field.java_name().should == 'int'
    end

    it "should return java name in a list when send #java_name(true)" do
      @field.java_name(true,true).should == 'List<Integer>'
    end
  
    it "should return a simple type for soap" do
      @field.soap_name.should == 'integer'
    end
  
    it "should return a simple type for qualified soap" do
      #just make sure it is something (xs or xsd)
      @field.namespace_abbr.should =~ /^xs/
      @field.qualified_soap_name.should == "#{@field.namespace_abbr}:integer"
    end 
  end
  describe "(via wsdl)" do
    before(:each) do
      name='sample'
      @wsdl=WsdlDef.parse name, {
        :namespace =>[name,"sample","com"],
        :namespace_abbr => "#{name}",
#        :file_name => file_name
      }
      #@wsdl.type 'Sample'
      @field=@wsdl['integer']
    end

    it "should return java name when send #java_name" do
      @field.java_name.should == 'int'
    end

    it "should return java name in a list when send #java_name(true)" do
      @field.java_name(true,true).should == 'List<Integer>'
    end

    it "should return a simple type for soap" do
      @field.soap_name.should == 'integer'
    end
  
    it "should return a simple type for qualified soap" do
      #just make sure it is something (xs or xsd)
      @field.namespace_abbr.should =~ /^xs/
      @field.qualified_soap_name.should == "#{@field.namespace_abbr}:integer"
    end 
  end
end