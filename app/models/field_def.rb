#TODO: decide split w/ exception?
## a field can be a class variable, method variable, or an fault variable
## this has a type and name
## for arrays, this has a minimum number and a max number ('unlimited' means ...)
class FieldDef < NamespacedNode
   
  UNBOUNDED="unbounded"

  attr_accessor :field_type, :min, :max

  def initialize(name,field_type, options={})
    super(name,"",options)
    @field_type=field_type

    @hidden=options[:hidden] == "true" || options[:hidden]==true

    if options[:array].nil? || options[:array] == false
      @min=nil
      @max=nil
    else
      @min=0
      @max=UNBOUNDED
    end

    #TODO: figure out best name for optional
    if options[:null]==true || options[:opt]==true||options[:optional]==true||@hidden
      @min=0
    end
    @min=options[:min] unless options[:min].nil?
    @max=options[:max] unless options[:max].nil?
  end

  def optional?()
    @min==0
  end

  #true if this is hidden from the wsdl
  def hidden?()
    @hidden
  end

  #this field is only used for output
  #TODO: fix this hack. should it go away?
  def output?()
    description =~ /[Oo]utput [Vv]alue/ || @field_type.description =~ /[Oo]utput [Vv]alue/
  end  
  
  def array?()
    @max==UNBOUNDED||@max.to_i>1
  end

  # soap

  #type for this field
  #used by xsd/wsdl
  def type_soap_name()
    @field_type.soap_name
  end

  def qualified_type_soap_name
    @field_type.qualified_soap_name
  end

  # java
  def type_java_name()
    @field_type.java_name(array?,optional?)
  end

  def to_s(prepend="")
    "#{prepend} field #{@name} #{type_soap_name}"
  end
end