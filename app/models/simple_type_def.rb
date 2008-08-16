## currently used for simple types
class SimpleTypeDef < NamespacedNode


  def self.all
    if not defined? @@types
      @@types=[]
      #skipped    'byte' 'decimal' 'integer' 'long' 'short' 'unsignedByte' 'unsignedInt' 'unsignedShort'
      ['boolean', 'dateTime','date','double', 'float','int', 'string', 'time', 'duration'].each do |name|
        @@types << SimpleTypeDef.new(name)
      end
    end
    @@types
  end
  #used for optionals or arrays
  @@java_objects={'boolean'=>'Boolean',
   'datetime'=>'Date',
   'date'=>'Date',
   'double'=>'Double',
   'float'=>'Float',
   'integer'=>'Integer',
   'int'=>'Integer',
   'string'=>'String',
   'time'=>'Date'}
  #used for primitives
  @@java_primitives={'boolean'=>'boolean',
   'datetime'=>'Date',
   'date'=>'Date',
   'double'=>'double',
   'float'=>'float',
   'integer'=>'int',
   'int'=>'int',
   'string'=>'String',
   'time'=>'Date'}

  def initialize(name)
    super(name,{:namespace => "http://www.w3.org/2001/XMLSchema", :namespace_abbr=>'xs', :plural => false, :file_name => ''})
  end

  #the name that this type goes by
  #this was defined by this name
  # for most namespaced_nodes
  def soap_name
    @name
  end

  ## display the java type
  ## basically convert the xsd types to java types
  def java_name(array=false,optional=false)
    if optional or array
      str2=@@java_objects[@name.downcase]
       
       str2="List<#{str2}>" if array
    else
      str2=@@java_primitives[@name.downcase]
   end
   str2
  end
  
  def complex?
    false
  end
  
  def to_s(prepend="")
    "#{prepend} simple_type #{soap_name}"
  end
end
