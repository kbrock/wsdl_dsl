## This is a struct / group of fields
## is a typedef used as method input/output lists, and class/struct member variables
class FieldsDef < NamespacedNode
  include Enumerable

  attr_accessor :fields

  ## was this defined or derived from something else (eg: plural)
  ## we typically don't want to display derived types in documentation
  attr_accessor :derived

  def initialize(name,options={})
    #remove the word fault and type from the name (sometimes they are specified in the dsl)
    #but they are present in the name_extension
    name.gsub!(/(Fault|Type)/) { "" }
    super(name,options)
    @lookup=options[:lookup]
    @derived=options[:derived]||false
    @fields=[]
  end

  # for enumerable
  def each(&block)
    fields.each &block
  end

#  def <<(entry)
#    @fields << entry
#  end

  def [](x)
    @fields[x]
  end

  ## does this have any fields
  def empty?()
    fields.empty?
  end

  #could be looking at name_extension (nil == simple, Enum == enum)
  def complex?
    true
  end

  ## in dsl define a field
  def field(f_type, f_name=nil, options={})
    #they did not pass in a name eg: passed in 'timecard', {:explode=>true} (will default name to type's name)
    if f_name.is_a?(Hash)
      options=f_name
      f_name=nil
    end
    #ensure that we have an array
    options||={}
    #explode says to expand complex types into multiple fields
    explode=options[:explode] == "true" || options[:explode] == true

    #they passed in a type, or the name of a type
    t = @lookup.find_type_by_name(f_type) unless @lookup.nil?
    #had name_ext here before (was nice to see request/response)
    raise "Could not find type #{f_type} while defining #{name}.#{f_name}" if t.nil?
    if f_name.nil?
      if options[:array]
        if defined? t.name.pluralize
          f_name=t.name.pluralize
        elsif t.name =~ /s$/
          f_name=t.name
        else
          f_name="#{t.name}s"
        end
      else
        f_name=t.name
      end
    end

    if explode
      exclude=options[:exclude]||[] #handle case where there are no exclusions
      exclude=[exclude] unless exclude.is_a?(Array) #handle single and plural cases
      t.fields.each do |f|
        #TODO: need a better clone process (but need to not copy the namespace)
        field_info={}
        #currently need name,field_type, min, max,description
        #min/max will take across array and optional
        field_info[:description]=f.description unless f.description.nil?
        field_info[:min]=f.min unless f.min.nil?
        field_info[:max]=f.max unless f.max.nil?
        #field_info[:array]="true" if f.array?
        field(f.field_type, f.name, field_info) unless exclude.include?(f.name)
      end
    else
      fld=FieldDef.new(f_name, t, options_array({:description=>t.description},options))
      fields<<fld
      fld
    end
  end

  #common ways to declare methods
  #alias bool boolean
  #alias int integer
  #alias double float

  #someone used a field name instead of 
   def method_missing(meth,*args)
     t = @lookup[meth.to_s]
     if t.nil?
       #otherwise, try and return a useful error message
       #had name_ext before - was nice to see which portion of a method had a problem
       raise "unknown type '#{meth}' used in '#{name}'. it may be misspelled or missing quotes."
     else #they are defining a type
       field(t,*args)
     end
   end

  def java_name(array=false,optional=false)
    if array
      "List<#{super}>"
    else
      super
    end
  end

  def to_s(prepend="")
    result=[]
    result << "#{prepend}fields #{@namespace_abbr}:#{@name}(#{@name_extension})"
    prepend=prepend+"   "
    fields.each do |f|
      result << "#{f.to_s(prepend)}" 
    end
    result.join "\n"    
  end
end