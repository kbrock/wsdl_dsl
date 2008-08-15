# a method has a struct for inputs, outputs, and a list of faults
class MethodDef < NamespacedNode
  attr_accessor :inputs, :outputs, :faults

  def initialize(name, options={})
    @lookup = options[:lookup]
    @faults=[]
    
    super(name,options)
    @inputs = FieldsDef.new "#{@name}",options_array(:type=>"Request", :lookup => @lookup)
    @outputs = FieldsDef.new "#{@name}",options_array(:type=>"Response", :lookup => @lookup)
  end

  ##TODO: need options_array here?
  def input(quick_type=nil, quick_name=nil, options=nil, &block)
    inputs.field(quick_type, quick_name, options) unless quick_type.nil?
    inputs.instance_eval(&block) if block_given?
  end

  ##TODO: need options_array here?
  def output(quick_type=nil,quick_name=nil, options={}, &block)
    outputs.field(quick_type,quick_name, options) unless quick_type.nil?
    outputs.instance_eval(&block) if block_given?
  end
  
  def fault?()
    @faults.empty == false
  end

  def fault(value=nil)
    if value.nil?
      @faults
    else
      @faults << @lookup.find_fault_by_name(value)
    end
  end

  # make the dsl easier - less to type
  alias in input
  alias out output

  # make the dsl easier: typically they are specifying a class that has already been defined
  def method_missing(meth,*args)
    #if they are doing a type definition, then they will include 
    t = @lookup[meth.to_s]
    if t.nil?
      #otherwise, try and return a useful error message
      raise "unknown phrase '#{meth}' used in '#{name}'. It may be misspelled or missing quotes."
    else #they are defining a type
      return t
    end
  end

  
  def to_s(prepend="")
    result=[]
    result << "#{prepend}method #{@namespace_abbr}:#{@name}"
    prepend=prepend+"   "
    result << "#{prepend}input\n#{@inputs.to_s(prepend)}" unless @inputs.empty?
    result << "#{prepend}output\n#{@outputs.to_s(prepend)}" unless @outputs.empty?
    result << "#{prepend}fault\n#{@fault.to_s(prepend)}" unless @fault.nil?
    result.join "\n"
  end
end