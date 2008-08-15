## currently used for simple types
class SimpleTypeDef < NamespacedNode

  #the name that this type goes by
  #this was defined by this name
  # for most namespaced_nodes
  def soap_name
    @name
  end

  def initialize(name)
    super(name,{:namespace => "http://www.w3.org/2001/XMLSchema", :namespace_abbr=>'xs', :plural => false, :file_name => ''})
  end

  ## display the java type
  ## basically convert the xsd types to java types
  def java_name(array=false,optional=false)
    if optional or array
      str2={'boolean'=>'Boolean',
       'datetime'=>'Date',
       'date'=>'Date',
       'double'=>'Double',
       'float'=>'Float',
       'integer'=>'Integer',
       'int'=>'Integer',
       'string'=>'String',
       'time'=>'Date'}[@name.downcase]
       
       str2="List<#{str2}>" if array
    else
      str2={'boolean'=>'boolean',
       'datetime'=>'Date',
       'date'=>'Date',
       'double'=>'double',
       'float'=>'float',
       'integer'=>'int',
       'int'=>'int',
       'string'=>'String',
       'time'=>'Date'}[@name.downcase]
   end
   str2
   #TODO: do str2||@name ?
  end
  
  def complex?
    false
  end
  
  def to_s(prepend="")
    "#{prepend} simple_type #{soap_name}"
  end
end
