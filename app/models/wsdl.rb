class Wsdl < ActiveRecord::Base
  
  has_and_belongs_to_many :xsds

  def code c=nil,external=true
    c||=WsdlDef.new name, {
      :namespace_array => [name,"services","company","com"],
      :namespace_abbr => "tns",
      :file_name => wsdl_file_name
      }
    c.host=host||"localhost"
    c.application=application||"application"
    #TODO: use path for the wsdl
    xsds.each do |x|
      begin
        x.code(c, external)
      rescue => e
        #would be nice to display just the message (line number too? use backtrace?)
        raise "trouble parsing #{x.name}, #{e}"
      end
    end unless xsds.nil?

    c.parse(contents) unless contents.nil?
    c
  end

  include CamelCase
  #only used by soap_name
  def cc_name()
    #@code.cc_name
#    name.to_s.gsub(/(^| )(.)/){$2.upcase}
    cc(name.to_s)
  end

  def soap_name()
    "#{cc_name}Service"     
  end

  #wsdl filename (internal)
  def wsdl_file_name 
    "/wsdl/#{name}.wsdl"
  end

  def zip_file_name()
    "java_#{name}_wsdl.zip"
  end
  
#  def to_param
#    name
#  end
end
