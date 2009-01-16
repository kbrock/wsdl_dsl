module CodeGen
  module JavaHelper
    #helper methods
    ## output imports
    def class_imports(obj,others=nil)
      lst=[]
      obj.methods.each do |m|
        add_imports(m.inputs.fields,lst)
        add_imports(m.outputs.fields,lst)
      end
      lst.push(*others) unless others.nil?

      lst.collect(){|l| "import #{l};"}.uniq.join("\n")
    end

    ## takes a list of fields or types
    def field_imports(obj,others=nil)
      lst=[]
      if obj.nil?
        obj=[]
      elsif obj.class!=Array #Could just be a collection?
        obj=[obj]
      end
      add_imports(obj,lst)
      lst.push(*others) unless others.nil?

      lst.collect(){|l| "import #{l};"}.uniq.join("\n")
    end

    def add_imports(obj,lst)
      return if obj.nil?
      obj.each do |f|
        if f.class == FieldDef and f.array?
          lst << 'java.util.List'
          lst << 'java.util.ArrayList'
        end
        if f.class == String
          lst << obj
        else #assume is a Simple, FieldsDef, or something else that can be imported
          if f.class==FieldDef
            ft=f.field_type
            #if it is a date field, then get date into imports
            if(java_name(ft)=='Date')
              lst << 'java.util.Date'
            end
          else #looping through all types in a file
            ft=f
          end
          if ft.complex?
            lst << "#{java_package(ft)}.#{java_name(ft)}" 
          end
        end
      end
    end

    #java comment
    def javacom(str, nl="\n * ")
      "/**"+
      str.gsub(/\n/,nl) +
      " */" unless str.nil? or str.empty?
    end  

    def java_package(t,join_char=".")
      raise "#{t.class}: #{t.name}" unless defined? t.namespace_array
      "#{t.namespace_array.reverse.join(join_char)}" #".#{t.name}"
    end

    def java_name(t,optional=false,array=false)
      type_name=t.name
      #simple types, need to use objects if in an array (or nullable)
       if optional or array
         str2={'boolean'=>'Boolean',
          'datetime'=>'Date',
          'date'=>'Date',
          'double'=>'Double',
          'float'=>'Float',
          'integer'=>'Integer',
          'int'=>'Integer',
          'string'=>'String',
          'time'=>'Date'}[type_name.downcase]
       else
         str2={'boolean'=>'boolean',
          'datetime'=>'Date',
          'date'=>'Date',
          'double'=>'double',
          'float'=>'float',
          'integer'=>'int',
          'int'=>'int',
          'string'=>'String',
          'time'=>'Date'}[type_name.downcase]
      end
      str2||t.cc(t.name_ext)
    end

    def java_var_name(t)
      java_name(t).gsub(/^(.)/) { |s| s.downcase}
    end

    ## display the java type
    ## basically convert the xsd types to java types
    def type_java_name(f)
      str2=java_name(f.field_type,f.array?,f.optional?)
      str2="List<#{str2}>" if f.array?
      str2
     #TODO: do str2||@name ?
    end

    def static_type_java_name(f)
      str2=java_name(f.field_type,f.array?,f.optional?)
      str2="ArrayList<#{str2}>" if f.array?
      str2
     #TODO: do str2||@name ?
    end
  end
end