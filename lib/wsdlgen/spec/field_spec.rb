describe FieldDef do
  describe "(via wsdl)" do
    before(:each) do
      name='sample'
      @wsdl=WsdlDef.parse name, {
        :namespace =>[name,"sample","com"],
        :namespace_abbr => "#{name}",
#        :file_name => file_name
      } do
        type 'Type1' do
          string 'x'
        end
        type 'Type2' do
          string 'str'
          integer 'f1', :array=>true
          Type1 't1'
          Type1 't1s', :array=>true
        end
      end
      @fields=@wsdl['Type2']
    end

    it "should find Sample type" do
      @fields.should_not be_nil
    end

    it "should return java name when send string#type_java_name" do
      @fields[0].type_java_name.should == 'String'
    end
    it "should return java name when send integer[]#type_java_name" do
      @field[1].type_java_name.should == 'List<Integer>'
    end
    it "should return java name when send Type1[]#type_java_name" do
      @field[2].type_java_name.should == 'Type1'
    end
    it "should return java name when send Type1[]#type_java_name" do
      @field[3].type_java_name.should == 'List<Type1>'
    end
  end  
end

