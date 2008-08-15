class Xsd < ActiveRecord::Base
  has_and_belongs_to_many :wsdls

  #external==false means this namespace is embedded in the current namespace
  def code(c=nil, external=true)
    if external==false
      #all these entries go into the existing file, namespace, filename and all
      c.instance_eval(contents) unless contents.nil?
    else
      #we get our own namespace and filename
      c2=WsdlDef.parse(name, {
        :namespace =>[name,"schemas","company","com"],
        :namespace_abbr => "data-#{name}",
        :file_name => xsd_file_name
      },contents)
      #if they passed in a class, then merge our stuff into theirs (keeping our own distinct namespace)
      c.concat(c2) unless c.nil?
    end

    #if they passed us in a wsdl_def, return that - else return the newly created one
    c||c2
  end

  #xsd filename (internal)
  def xsd_file_name
    "/wsdl/#{name}.xsd"
  end  

  def zip_file_name()
    "java_#{name}_xsd.zip"
  end

#  def to_param
#    name
#  end
end
