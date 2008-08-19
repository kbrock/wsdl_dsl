class Wsdl < ActiveRecord::Base
  include CamelCase
  
  has_and_belongs_to_many :xsds

  def code c=nil,external=true
    c||=WsdlDef.new name, {
      :namespace_array => namespace.split(","),
      :namespace_abbr => namespace_abbr,
      :file_name => wsdl_file_name
      }
    c.host=host||"localhost"
    c.application=application||"application"

    #define structures from referenced xsds
    xsds.each do |x|
      begin
        x.code(c, external)
      rescue => e
        raise "trouble parsing #{x.name}, #{e}"
      end
    end unless xsds.nil?

    # define data structures from the wsdl
    c.parse(contents) unless contents.nil?
    c
  end

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
