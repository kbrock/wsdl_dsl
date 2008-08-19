class WsdlDef < NamespacedNode

  #these help create the url
  attr_accessor :host, :application
  #TODO: merge types and enumeratins
  #NOTE: faults was in there, but there were too many 'except for faults' clauses
  attr_accessor :methods, :faults, :types, :enumerations

#getters

  def service_url()
    "http://#{host}/#{application}/services/#{cc_name}Service"
  end

  ## defined to come up with all the other soap names (instead of defining every one of them)
  def cc_name
    cc @name
  end
  
  ## types that have filenames associated with them
  # used to produce files
  def external_types()
    ret=[]    
  	types.each do |t|
    	#don't import without a filename and duplicates
			ret << t unless t.file_name.nil? or t.file_name == file_name or ret.any? { |tt| t.file_name == tt.file_name }
    end
    ret
  end

  def local_types()
  	types.select { |t| t.file_name == file_name }
  end 
  
  def local_enumerations()
  	enumerations.select { |t| t.file_name == file_name }
  end

  def local_faults()
  	faults.select { |t| t.file_name == file_name }
  end
  
  ## types that have unique namespaces
  # used at head of file to declare unique namespaces
  def namespaces()
    ret=[self]
  	types.each do |t|
    	ret << t unless ret.any? { |tt| t.namespace_abbr == tt.namespace_abbr }
    end
    ret
  end
                               
  def initialize(wsdl_name, options)
    @methods=[]
    @faults=[]
    @types=[]
    @enumerations=[]
    super(wsdl_name.to_s,'PortType',options)

    #define default schema types
    @types.push *SimpleTypeDef.all
  end
  
  def self.parse(wsdl_name,options,str=nil, &block)
    w=WsdlDef.new(wsdl_name,options) 
    #w.parse(str,&block)
    w.instance_eval(str) unless str.nil?
    w.instance_eval(&block) if block_given?
    w
  end

  def parse(str,&block)
    instance_eval(str) unless str.nil?
    instance_eval(&block) if block_given?
  end

  ##generic find
  def [](name)
    find_type_by_name(name)||find_fault_by_name(name)
  end

  #had both as one method, decided to split out
  def find_fault_by_name(name)
    find_by_name(name,@faults, /[Ff]ault$/)
  end

  def find_type_by_name(name)                                  
    find_by_name(name,@types, /[Tt]ype$/)||find_by_name(name,@enumerations)
  end

  def find_by_name(name,collection, regex=nil)
    return name if name.nil? || name.class != String #name.is_a?(FieldsDef) || name.is_a?(EnumerationDef) #|| name.is_a?(TypeDef)
    name=name.to_s
    name=name.gsub(regex) {''} unless regex.nil?
    name=name.upcase

    raise "#{collection.class} did not define find" unless defined?(collection.find)
    collection.find  { |t| t.name.upcase == name }
  end

  def create_type(name, options={})
    options2 = options_array({:type=>"Type",:lookup=>self},options)
    plural_name=options2.delete(:plural)

    #enumeration
    #type 'applicationStatus', :values=>['NEW','ACCEPTED','REJECTED']
    if options2[:values]
      values=options2[:values]
      if values[0].is_a? Numeric
        values_type=find_type_by_name('integer')
      else
        values_type=find_type_by_name('string')
      end
      t=find_type_by_name values_type
      e = EnumerationDef.new name,t,values,options2
      @enumerations << e
      e
    else
      #define the complex type
      fld=FieldsDef.new name, options2
      @types << fld

      #define the plural version of the field
  #    unless plural_name == false || plural_name == "false" || plural_name == ''
      unless plural_name == false || plural_name == "false" || plural_name == '' || plural_name.nil?
        #add check if pluralize is defined
        
        plural_name=name.pluralize if plural_name.nil? or plural_name == true

        plural_name = plural_name.to_s

        options2[:description]="many #{plural_name}.\n#{options2[:description]}"
        options2[:derived]=true
        fld2=FieldsDef.new plural_name, options2
        fld2.field fld, {:array=>true}.merge(options2)
        @types << fld2
      end #plural
      fld
    end
  end

  ## dsl: define a complex type
  def type(name, options={}, str=nil, &block)
    f=create_type(name,options)
    f.instance_eval(str) unless str.nil?
    f.instance_eval(&block) if block_given?
    f
  end

  def create_fault(name=nil,options={})
  end
  
  ##dsl: define a fault
  def fault(name=nil, options={}, &block)
    name||="#{cc_name}ServiceFault" 
    options2 = options_array({:type=>"Fault",:lookup=>self},options)
    f=FieldsDef.new name, options2
    @faults << f
    f.instance_eval(&block) if block_given?
    f
  end
  
  def method(name, options={}, str=nil, &block)
    options2= options_array({:lookup=>self},options)
    meth=MethodDef.new name, options2
    @methods << meth
    meth.instance_eval(str) unless str.nil?
    meth.instance_eval(&block) if block_given?
    meth
  end

  #add all the elements in wsdl2 into this current element
  def concat(wsdl2)
    types.concat(wsdl2.types)
    enumerations.concat(wsdl2.enumerations)
    faults.concat(wsdl2.faults)
    methods.concat(wsdl2.methods)
  end

  ## dsl: create default crud methods  
  def crud(single,plural=nil,flt=nil,options={})
    single=find_type_by_name single
    
    #pick a fault if one is not specified
    unless flt == false
      flt_name=flt||"#{cc_name}ServiceFault"
      flt=find_fault_by_name flt
      if flt.nil?
        fault flt_name do
          string 'Message'
        end
      end
    end

    method "Retrieve#{cc single.name.pluralize}" do
      output single, :array => true
      fault flt unless flt.nil?
    end

    method "Create#{cc single.name}" do
      input single, :explode => true, :exclude=> ['id','ID','Id']
      output single, :array => true
      fault flt unless flt.nil?
    end
    method "Retrieve#{cc single.name}" do
      input string, 'id'
      output single
      fault flt unless flt.nil?
    end
    method "Update#{cc single.name}" do
      input single, :explode => true
      output single
      fault flt unless flt.nil?
    end
    method "Delete#{cc single.name}" do
      input string, 'id'
      fault flt unless flt.nil?
    end
  end

  ##dsl
  def method_missing(meth,*args)
    #if they are doing a type definition, then they will include 
    t = find_type_by_name(meth.to_s)||find_fault_by_name(meth.to_s)
    if t.nil?
      raise "unknown phrase '#{meth}'. It may be misspelled or missing quotes."
    else #they are defining a type
      return t
    end
  end

#remove
#  def wsdl()
#    wsdl_template=ERB.new(IO.read(File.dirname(__FILE__) +'/templates/wsdl.erb'),nil,"-")
#    @code=self
#    wsdl_template.result(binding)
#  end

  ##test method  
  def to_s(prepend="")
    result=[]
    result << "#{prepend}wsdl #{@namespace_abbr}:#{@name}"
    result << "schema namespace: #{types.first.namespace_abbr}"
    result << "code namespace: #{namespace_abbr}"
  	
    prepend=prepend+"   "
    result << "#{prepend}types"
    @types.each do |s|
      result << "#{s.to_s(prepend)}"
    end
    result << "#{prepend}enumerations"
    @enumerations.each do |e|
      result << "#{e.to_s(prepend)}"
    end
    result << "#{prepend}faults"
    @faults.each do |f|
      result << "#{f.to_s(prepend)}"
    end
    result << "#{prepend}methods"
    @methods.each do |m|
      result << "#{m.to_s(prepend)}"
    end
    result.join "\n"
  end
end
