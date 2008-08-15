require File.dirname(__FILE__) + '/../wsdlgen.rb'

describe FieldsDef do
  
  describe "(direct)" do
    before(:each) do
      @fields=FieldsDef.new 'Sample', {:type=>'Type', :namespace => 'com.sample', :namespace_abbr => 'sample'}
    end
  
    it "should return java name when send #java_name" do
      @fields.java_name().should == 'SampleType'
    end

    it "should return java name in a list when send #java_name(true)" do
      @fields.java_name(true,true).should == 'List<SampleType>'
    end
  end

  describe "(via wsdl)" do
    before(:each) do
      name='sample'
      @wsdl=WsdlDef.parse name, {
        :namespace =>[name,"sample","com"],
        :namespace_abbr => "#{name}",
#        :file_name => file_name
      } do
        type 'Sample'
      end
      @fields=@wsdl['Sample']
    end

    it "should find Sample type" do
      @fields.should_not be_nil
    end

    it "should return java name when send #java_name" do
      @fields.java_name().should == 'SampleType'
    end

    it "should return java name in a list when send #java_name(true)" do
      @fields.java_name(true,true).should == 'List<SampleType>'
    end
  end
  describe "(via wsdl/method)" do
    before(:each) do
      name='sample'
      @wsdl=WsdlDef.parse name, {
        :namespace =>[name,"sample","com"],
        :namespace_abbr => "#{name}",
#        :file_name => file_name
      } do
        method 'm1' do
          input datetime 'f1'
          output string, 's1', :array=>true
        end
      end
      @method=@wsdl.methods[0]
      @input=@method.input
      @output=@method.output
    end

    it "should find method" do
      @method.should_not be_nil
      @method.name.should == "m1"
    end

    it "should return correct java name when send input#java_name" do
      @method.inputs.fields.first.type_java_name.should == 'Date'
    end

    it "should be min 0" do
      fld=@method.outputs.fields.first
      fld.min.should == 0
    end
    it "should be min 0" do
      fld=@method.outputs.fields.first
      fld.max.should == "unlimited"
    end
    it "should be an array output" do
      fld=@method.outputs.fields.first
      fld.array?.should be_true
    end
    it "should return correct java name when sent output#java_name" do
      fld=@method.outputs.fields.first
      fld.type_java_name.should == 'List<String>'
    end
  end
end

