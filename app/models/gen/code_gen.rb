## Template generator
module Gen
  class CodeGen
    class JavaTemplate < Gen:CodeTemplate
      def initialize(name, offset,src=nil)
        compile(name,offset,src, Gen:JavaHelper)
      end

      def run(obj,objname)
        run_template(binding)
      end
    end

    #public methods
    def show_struct(obj)
      @struct_template.result(binding)
    end

    def create_zip(code, filename)
      if File.file?(filename)
        File.delete(filename)
      end
     
      z=Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) { |zip|
        write_template(zip,code,@package_info_template,"","package-info.java")
        write_template(zip,code.local_enumerations,@enum_template)

        create_type(code.local_types,zip)
        create_type(code.faults,zip)
        #do the faults here? write_template(zip,)
        code.methods.each do |m|
          create_type(m.inputs,zip)
          create_type(m.outputs,zip)
          create_type(m.faults,zip)
          write_template(zip,m.faults,@fault_template,'_Exception')
       end
       unless code.methods.empty?
         write_template(zip,code,@code_template)
         write_template(zip,code,@sample_template,'Sample')
         write_template(zip,code,@factory_template,'Factory')
       end 
      }
      File.chmod(0644, filename)
    end
  
    def initialize()
      @enum_template=JavaTemplate.new('enum',179,%q{package <%=java_package(obj)%>;

  <%= javacom obj.description %>
  public enum <%=objname%> {
  <% obj.values.each do |v| -%>
  	<%=v%>,
  <% end -%>	
  }
  })
      @struct_template=JavaTemplate.new('code',188,%q{package <%=java_package(obj)%>;

  <%= field_imports(obj.fields) %>
  <%= field_imports(nil, %w{javax.xml.bind.annotation.XmlAccessType javax.xml.bind.annotation.XmlAccessorType javax.xml.bind.annotation.XmlElement javax.xml.bind.annotation.XmlType})%>
  <%= field_imports(nil,'javax.xml.bind.annotation.XmlRootElement') if obj.element? %>
  <%= field_imports(nil,'javax.xml.bind.annotation.XmlTransient') if obj.detect { |f| f.hidden?} %>

  @XmlAccessorType(XmlAccessType.FIELD)
  <% if obj.element? #if it is an element, then minimal type -%>
    @XmlType(name = "", <% -%>
  <% else #regular types have information here but not in xmlroot element -%>
  @XmlType(name = "<%=java_name(obj)%>", namespace="<%=obj.soap_namespace%>", <% -%>
  <% end #element nodes-%>
  propOrder = {
      <%= obj.fields.select {|f| not f.hidden?}.collect(){ |f| "\"#{java_var_name(f)}\"" }.join(",\n    ") %>
  })
  <% if obj.element? #if it is an element, then tack on an element node -%>
  @XmlRootElement(name = "<%=obj.soap_name%>", namespace = "<%=obj.soap_namespace%>")
  <% end #element -%>
  public class <%=objname%> implements Cloneable {
  	  /* member variables */

  <% obj.fields.each do |f| #each field -%>
  	  <%= javacom "#{f.description}","\n\t  * " %>
  <%# TODO: dont need name if java name is same as soap attribute name (currently f.name)-%>
  <%   if f.hidden? #hidden attributes not in wsdl -%>
      @XmlTransient
  <%   else -%>
      @XmlElement(name = "<%=f.name%>"<%=", required=true" unless f.optional?%>)
  <%   end #hidden attributes not in wsdl -%>
  <% if false and type_java_name(f) == 'Date' #a date-%>
    private XMLGregorianCalendar xml<%=java_name(f)%>;
    /** cached copy of xml<%=java_name(f)%> as a {@see java.util.Date} */
    @XmlTransient
  <% end #a date -%>
  	  private <%=type_java_name(f)%> <%=java_var_name(f)%>;
  <% end #each field-%>

      /* constructors */
      public <%=objname%>() {
        /**/
      }

      public <%=objname%>(<% -%>
  <%# wanted to do a simple each, but don't know how to join all with , except for last one -%>
  <%= obj.fields.collect(){ |f| "#{type_java_name(f)} #{java_var_name(f)}" }.join(", ") -%>) {
  <% obj.fields.each do |f| -%>
          set<%=java_name(f)%>(<%= java_var_name(f)%>);
  <%#  		  this.<%=java_var_name(f)% > = <%= java_var_name(f)% >; -%>
  <% end #each field -%>
      }

        public <%=objname%>(<%=objname%> src) {
  <%# wanted to do a simple each, but don't know how to join all with , except for last one -%>
  <%
    #TODO: what to do about complex entries?
    obj.fields.each do |f|
      -%>
            set<%=java_name(f)%>(src.get<%=java_name(f)%>());
  <%
    end #each field
  -%>
        }

  	/* getter and setter methods */

  <% obj.fields.each do |f| #each field-%>
  	  public <%=type_java_name(f)%> get<%=java_name(f)%>() {
  <% if f.array? #for arrays, make sure they are not null -%>	    
          if (this.<%=java_var_name(f)%> == null) {
              this.<%=java_var_name(f)%> = new ArrayList<<%=java_name(f.field_type)%>>();
          }
  <% end #non null arrays -%>
  		    return this.<%=java_var_name(f)%>;
  	  }
  	  public void set<%=java_name(f)%>(<%=type_java_name(f)%> <%=java_var_name(f)%>) {
  		    this.<%=java_var_name(f)%> = <%=java_var_name(f)%>;
  	  }

  <% end #each field-%>

      @Override
      public String toString() {
          StringBuffer sb = new StringBuffer();
          sb.append("<@").append(super.hashCode());
  <%
     obj.fields.each do |f| #each field
       unless f.array? #we want to use it-%>
    <%     if f.field_type.complex? or java_name(f.field_type)=='Date' -%>
          if (get<%=java_name(f)%>()!=null)
  <%     end #is complex -%>
              sb.append("; <%=f.name%>=").append(get<%=java_name(f)%>());
  <%
       end #we want to use it
     end #each field
  -%>  		
        sb.append(">");
        return sb.toString();
      }

      @Override
      public Object clone() throws CloneNotSupportedException {
      	return super.clone();
      }
  }
  })
      @code_template_old=JavaTemplate.new('old_code',294,%q{package <%=java_package(obj)%>;

  public interface <%=objname%> {
  <% obj.methods.each do |m| -%>
    <%= javacom m.description %>
    <%= java_name(m.outputs)%> <%=java_var_name(m)%>(<%=java_name(m.inputs) %> req<%#=m.inputs.name%>);
  <% end -%>
  }
  })

      #since referenced classes are in the current package, no need for those imports
      @code_template=JavaTemplate.new('code',305,%q{package <%=java_package(obj)%>;

  <%= field_imports(nil, %w{javax.jws.WebMethod javax.jws.WebParam javax.jws.WebResult javax.jws.WebService javax.jws.soap.SOAPBinding javax.xml.bind.annotation.XmlSeeAlso})%>

  @WebService(name = "<%=obj.soap_name%>", targetNamespace = "<%=obj.soap_namespace%>")
  @SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
  @XmlSeeAlso({                                                                   
      <%=java_name(obj)%>Factory.class
  })
  public interface <%=objname%> {
  <% obj.methods.each do |m| #methods -%>
      @WebMethod(action = "/<%=m.name%>")
      @WebResult(name = "<%=m.outputs.soap_name%>", targetNamespace = "<%=m.outputs.soap_namespace%>", partName = "parameters")
      public <%=java_name(m.outputs)%> <%=java_var_name(m)%>(
          @WebParam(name = "<%=m.inputs.soap_name%>", targetNamespace = "<%=m.inputs.soap_namespace%>", partName = "parameters")
          <%=java_name(m.inputs)%> parameters)
  <%=
       "throws #{m.faults.collect { |f| "#{java_name(f)}_Exception"}.join(",")}" unless m.faults.empty?
  %>;
  <% end #methods -%>
  }
  })
  #TODO: figure out imports <%#= field_imports(obj.methods) %>
      @sample_template=JavaTemplate.new('sample',228,%q{package <%=java_package(obj)%>;

  <%=class_imports(obj,%w{javax.jws.WebService})%>

  @WebService(serviceName = "<%=obj.cc_name%>Service", targetNamespace = "<%=obj.soap_namespace%>", endpointInterface = "<%=java_package(obj)%>.<%=java_name(obj)%>")
  public class <%=objname%> implements <%=java_name(obj)%> {

  <% obj.methods.each do |m| #methods-%>
      public <%= java_name(m.outputs)%> <%=java_var_name(m)%>(<%=java_name(m.inputs)%> req)
  <%=
       "throws #{m.faults.collect { |f| "#{java_name(f)}_Exception"}.join(",")}" unless m.faults.empty?
  %>
      {
  <%    m.inputs.fields.each do |f| #inputs-%>
          <%=type_java_name(f)%> <%=java_var_name(f)%> = req.get<%=java_name(f)%>();
  <%    end #inputs-%>

          <%=java_name(m.outputs)%> resp = new <%=java_name(m.outputs)%>();
  <%    m.outputs.fields.each do |f| #outputs -%>
          <%=type_java_name(f)%> <%=java_var_name(f)%> = new <%=static_type_java_name(f)%>();
  <%    end #outputs -%>

  <%    m.outputs.fields.each do |f| #outputs -%>
          resp.set<%=java_name(f)%>(<%=java_var_name(f)%>);
  <%    end #outputs -%>

          return(resp);
      }
  <% end #methods -%>
  }
  })
      @fault_template=JavaTemplate.new('fault',359,%q{package <%=java_package(obj)%>;

  <%= field_imports(nil, %w{javax.xml.ws.WebFault})%>

  @WebFault(name = "<%=obj.soap_name%>", targetNamespace = "<%=obj.soap_namespace%>")
  public class <%=objname%>
      extends Exception
  {
  	  private static final long serialVersionUID = 1L;
      private <%=java_name(obj)%> faultInfo;

      public <%=java_name(obj)%>_Exception(String message) {
      	super(message);
      	<%=java_name(obj)%> fi = new <%=java_name(obj)%>();
      	fi.setMessage(message);
      	//TODO: put all the fields into faultInfo?
          this.faultInfo = fi;
      }
      public <%=objname%>(String message, <%=java_name(obj)%> faultInfo) {
          super(message);
          this.faultInfo = faultInfo;
      }

      public <%=objname%>(String message, <%=java_name(obj)%> faultInfo, Throwable cause) {
          super(message, cause);
          this.faultInfo = faultInfo;
      }

      public <%=java_name(obj)%> getFaultInfo() {
          return this.faultInfo;
      }
  }

  })
      @factory_template=JavaTemplate.new('factory',393,%q{package <%=java_package(obj)%>;

  <%= field_imports(obj.types, %w{javax.xml.bind.annotation.XmlRegistry})%>

  @XmlRegistry
  public class <%=objname%> {
    public <%=objname%>() {
      /* empty constructor */
    }
  
  <% obj.types.each do |t| #types
       if t.complex? #only complex types-%>
      public <%=java_name(t)%> create<%=java_name(t)%>() {
        return new <%=java_name(t)%>();
      }
  <%   end #only complex types
     end #types -%>
  }
  })
      @package_info_template=JavaTemplate.new('package',412,%q{@javax.xml.bind.annotation.XmlSchema(namespace ="<%=obj.soap_namespace%>", elementFormDefault = javax.xml.bind.annotation.XmlNsForm.QUALIFIED)
  package <%=java_package(obj)%>;
  })
    end

    def create_type(t,zip)
      #write_template(zip,t,@interface_template,nil,@struct_template,"Impl")
      write_template(zip,t,@struct_template)
    end

    #takes 2 templates because there is the example of doing interface and implementation
    #currently only pass in one
    #TODO: use var args way to loop through the templates
    def write_template(zip,t,template,ext="", filename=nil)
      t=[t] if t.class != Array
      t.each do |obj|
        objname="#{template.java_name(obj)}#{ext}"
        ofilename=filename||"#{objname}.java"
  #      RAILS_DEFAULT_LOGGER.info "adding to zip: #{ofilename}..."
        zip.get_output_stream("#{template.java_package(obj,'/')}/#{ofilename}") { |f|
          f.write(template.run(obj,objname))
        }
      end
    end
  end
end
