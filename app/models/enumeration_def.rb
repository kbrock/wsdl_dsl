#TODO: decide merge w/ field_def?

## enumerations have possible values.
## this is a type_def
## in Java, these do not have a base field_type, in wsdl they do
## In Java, they potentially have numbers?, may need to extend to handle this
class EnumerationDef < NamespacedNode
  #soap base type - the type that is used by the enum (String, Int, ...)
  attr_accessor :field_type
  ## values for this enum
  attr_accessor :values

  def initialize(name,field_type,values, options)
    @field_type=field_type
    @values=values
    super(name,'enum',options)
  end

  def complex?
    false
  end

  def to_s(prepend="")
    result=[]
    result<<"#{prepend}enumeration #{@name} #{@field_type.name} {"
    values.each do |v|
      result<<"#{prepend}   #{v}"
    end
    result<<"#{prepend}}"
    result.join "\n"
  end
end
