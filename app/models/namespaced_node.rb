## base node for representing methods, enumerations, and structs
class NamespacedNode
  #add cc function
  include CamelCase

  # name is the underscore (and lower case) name used to reference this class
  attr_accessor :name
  # name_extension is typically appended onto the end of a name when generating the name to be used as a class or wsdl name
  attr_accessor :name_extension
  # file_name 
  attr_accessor :file_name, :namespace_abbr #,:namespace, :namespace_array
  attr_accessor :description

  # take (name,options) or (name,type,options)
  def initialize(name,name_extension,options=nil)
    # handle (name,options) case
    if(name_extension.class == Hash)
      options=name_extension
      name_extension=options[:type]
    end

    @name=name
    @name_extension=name_extension
    @name_extension=nil if @name_extension == ""

    options={} if options.nil?

    @namespace=options[:namespace]
    @namespace_array=options[:namespace_array]
    
    #they can pass in namespace as an array
    #TODO: do more here
    if @namespace_array.nil?
      #TODO: railse "issue #{@name} - not specifying namespace_array (gave namespace of #{@namespace})"
      @namespace_array=@namespace
      @namespace=nil
    end
    
    if @namespace_array.class == String
      raise "issues #{@name} - #{@namespace_array}" if @namespace_array[/urn:/]
    elsif @namespace_array.nil?
      raise "#{name} missing namespace"
    else
      @namespace="urn:#{@namespace_array.join('-')}:#{name}" if @namespace.nil?
    end

    @namespace_abbr=options[:namespace_abbr]

    @file_name=options[:file_name]
    @file_name=nil if @file_name == ""
    
    @description=options[:description] 
  end
  
  def name_ext
    if (@name_extension.nil? )
      "#{@name}"
    else
      "#{@name}_#{name_extension}"
    end
  end

  # TODO: move to java module

  def java_namespace(join_char=".")
    @namespace_array.reverse.join(join_char)
  end

  ## TODO: in java, don't include the name extension at the end
  # subclasses need these parameters. couldn't figure out how to not
  # pass all these parameters when subclass was calling super
  
  # structs currently used for req/resp. needed to add extensions back in
  def java_name(array=false,optional=false)
    cc(name_ext)
  end

  def java_package
    "#{@namespace_array.reverse.join(".")}.#{name}"
  end

  # TODO: move to soap module
  def soap_name
    cc(name_ext)
  end

  #soap namespace
  def soap_namespace() 
    @namespace
  end

  ##used by soap (cc and ext are assumed)
  def qualified_soap_name
    "#{@namespace_abbr}:#{soap_name}"
  end

  def namespace_array()
    @namespace_array
  end

  #Request, Response, Faults are defined as simple elements, types and enums are defined as complex types  
  def element?
    ['Request','Response','Fault'].include?(@name_extension)
    #alternative is "Type" - don't know about enumeration
  end

  def fault?
    @name_extension == 'Fault'
  end
  
  #easier way to set description (rather then passing into constructor)
  def describe(str=nil)
    @description=str unless str.nil?
    @description
  end
  
  # serialize these options so they can be propigated to children
  def options_array(default_values=nil,options=nil) 
    #skipping name and name_extension
    o={:namespace_array => @namespace_array, :namespace =>@namespace, :namespace_abbr=>@namespace_abbr, :file_name => @file_name}
    o=o.merge(default_values) unless default_values.nil?
    o=o.merge(options) unless options.nil?
    o
  end
end