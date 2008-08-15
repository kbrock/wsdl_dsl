module Gen
class DotGen
  #exact will link to this exact location. unfortunatly it ends up with extra lines. so this is disabled for now

  def wsdl_dot(code,ignore=[])
    ignore=fix_ignore(ignore)
    @wsdl_template.result(binding)
  end

  def xsd_dot(code,ignore=[])
    ignore=fix_ignore(ignore)
    @xsd_template.result(binding)
  end

  #helper
  def fix_ignore(ignore)
    if ignore.nil?
      ignore=[]
    elsif ignore.class==String
      ignore=ignore.split(',')
    else
      ignore
    end
  end
  
  def initialize()
    @exact=false    
    @wsdl_template=ERB.new(%q{
#
#  service <%=code.name%>
#
<%
  #We want to make sure we output all referenced types. And we want to link to them

  #list of all the complex types that need to be defined.
  #true means it is defined, false means it needs to be defined
  defined={}
  ignore.each do |f| #for each ignored parameter
	defined[f]=true #mark it that we have already defined it
  end
-%>
digraph <%= code.name %> {
	label="<%= code.name %>"
	node [ shape=Mrecord, color="#3d6b8e", fontcolor="#334466", width="1.2", fillcolor="#eeeeee", style=filled ]
#for edge arrowhead="none", 
	edge [ color="#3d6b8e", labelcolor="#334466"]
	subgraph {
		rank="same";

<% code.methods.each do |m| #all the methods
-%>
		<%=m.name%> [label="{<%=m.name -%>}"]

		<%=dot_struct(m.inputs,"#{m.name}_inputs","inputs")%>
		<%=dot_struct(m.outputs,"#{m.name}_outputs","outputs")%>
        <%=m.name%>_inputs -> <%=m.name%> -> <%=m.name%>_outputs  [minlen=3]
	}
<% end #methods-%>

	// these are referenced from the inputs/outputs to complex types
	//putting outside the subgraph to show on another line
	//edge [ style=dashed]
	node [ style=none ]
<%
code.methods.each do |m| #methods
-%>
<%= dot_links(m.inputs,"#{m.name}_inputs",defined,ignore) %>
<%= dot_links(m.outputs,"#{m.name}_outputs",defined,ignore) %>
<%   m.faults.each do |f| #faults
	   #unless ignore[f.name].nil?
	defined[f.name]=false if defined[f.name].nil?

-%>
		<%=m.name%> -> <%=f.name%>
<%
       #end #ignore
     end #faults -%>
<%
end #methods
-%>
  //references from method objects to detailed nodes
<%=
  dot_recurse(defined,ignore,code)
-%>
}
},nil,"-")
    @xsd_template=ERB.new(%q{
#
#  xsd <%=code.name%>
#
<%
  #We want to make sure we output all referenced types. And we want to link to them

  #list of all the complex types that need to be defined.
  #true means it is defined, false means it needs to be defined
  defined={}
  ignore.each do |f| #for each ignored parameter
	defined[f]=true #mark it that we have already defined it
  end
-%>

digraph <%= code.name %> {
	label="<%= code.name %>"
	node [ shape=Mrecord, color="#3d6b8e", fontcolor="#334466", width="1.2", fillcolor="#eeeeee", style=filled ]
	edge [ color="#3d6b8e", labelcolor="#334466", minlen="1.2"]
<% code.local_types.each do |t| #all local types -%>
<%#   unless t.derived #don't do derived types -%>
<%= dot_struct(t,nil,nil,defined) %>
<%= dot_links(t,nil,defined,ignore) %>
<%#   end #derived types-%>
<% end #all local types-%>
<% code.local_faults.each do |t| #all local faults -%>
<%#   unless t.derived #don't do derived types -%>
<%= dot_struct(t,nil,nil,defined) %>
<%= dot_links(t,nil,defined,ignore) %>
<%#   end #derived types-%>
<% end #all local faults-%>
	
	// these are referenced from local types to external types
	// show these a little differently
	edge [ style=dashed]
	node [ style=none ]
<%=
  dot_recurse(defined,ignore,code)
-%>
}
},nil,"-")

  end
  ## helper methods
  def dot_struct(s,name=nil,label=nil, defined=nil)
    defined[s.name]=true if not defined.nil?
    rslts=[]
    rslts << "#{name||s.name} [label=\"{#{label||name||s.name}#{'|' unless @exact}"
    qualifier=""
    s.fields.each do |f| #fields in the method
      qualifier = "|<#{f.name}> " if @exact
      fname=f.name
      fname="#{fname}[]" if f.array?
      if f.hidden?
        fname="((#{fname}))"
      else
        fname="(#{fname})" if f.optional? and not f.output? and not f.array?
      end
      fname="#{fname} *" if f.output?
      rslts << "#{qualifier}#{fname}\\l"
    end #fields in the method
    rslts << "}\"]"

    rslts.join("")
  end

  def dot_links(s,name=nil,defined=[],ignore=[])
    rslts=[]
    if @exact
      qualifier="#{name||s.name}:"
    else
      qualifier=""
    end
    s.fields.each do |f| #fields
      if f.field_type.complex? and not ignore.include?(f.field_type.name) # only link to detailed types
    		#if it hasn't been defined, then mark that we need more information
  		  defined[f.field_type.name]=false if defined[f.field_type.name].nil?
  		  if @exact
  		    src="#{qualifier}#{f.name}"
 		      src_compass="e"
		    else
		      src="#{name||s.name}"
	        src_compass="s"
	      end
  		  if f.field_type == s #link to myself
     		  rslts<< "#{src}:e -> #{src}:e"
   		  else #don't link to myself
     		  rslts<< "#{src}:#{src_compass} -> #{f.field_type.name}:n [len=0.2]"
   		  end #don't link to myself
  	  end #link to detailed types
    end #fields
    rslts.join("\n")
  end

  def dot_recurse(defined,ignore,lookup)
    rslts=[]
    while defined.has_value?(false) do #need to define something
    	defined.each do |n,v| #complex types referenced
    	  unless v # if we still need to define this thing
    	    s=lookup[n]
    	    raise "couldn't find type #{n}" if s.nil?
    	    rslts << dot_struct(s,nil,nil,defined)
    	    raise "for some reason didn't set #{n} to true " unless defined[n]==true
    	    rslts << dot_links(s,nil,defined,ignore)
    	  end # if we still need to define this thing
    	end #complex types 
    end #have something to define
    rslts.join("\n")
  end
end
end