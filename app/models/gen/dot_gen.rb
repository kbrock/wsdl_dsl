module Gen
  class DotGen
    class DotTemplate < Gen::CodeTemplate

      def initialize(name, offset,src=nil)
        compile(name,offset,src, Gen::DotHelper)
      end
      
      def fix_ignore(ignore)
        if ignore.nil?
          ignore=[]
        elsif ignore.class==String
          ignore=ignore.split(',')
        else
          ignore
        end
      end
      
      def run(code,ignore=[])
        ignore=fix_ignore(ignore)
        run_template(binding)
      end
    end
    #exact will link to this exact location. unfortunatly it ends up with extra lines. so this is disabled for now
    def wsdl_dot(code,ignore=[])
      @wsdl_template.run(code,ignore)
    end

    def xsd_dot(code,ignore=[])
      @xsd_template.run(code,ignore)
    end

    def initialize()
      @exact=false    
      @wsdl_template=DotTemplate.new("dot",105,%q{
#
#  service <%=code.name%>
#
digraph <%= code.name %> {
	label="<%= code.name %>"
	node [ shape=Mrecord, color="#3d6b8e", fontcolor="#334466", width="1.2", fillcolor="#eeeeee", style=filled ]
	edge [ color="#3d6b8e", labelcolor="#334466"]
<%
  #list of all the complex types that are referenced / need to be defined.
  # true means it is defined, false means it needs to be defined
  defined={}
  ignore.each do |f| #for each ignored parameter
	  defined[f]=true #mark it that we have already defined it
  end

  p_m = nil
  code.methods.each do |m| #all the methods
-%>
#  subgraph <%=m.name%>_cluster {
    subgraph <%=m.name%>_s {
  	  rank="same";
  		<%=m.name%> [label="{<%=m.name -%>}"]

  		<%=dot_struct(m.inputs,"#{m.name}_inputs","inputs")%>
  		<%=dot_struct(m.outputs,"#{m.name}_outputs","outputs")%>
      <%=m.name%>_inputs -> <%=m.name%> -> <%=m.name%>_outputs  [minlen=3]
  	}
#  }
<%= "#{p_m.name} -> #{m.name} [style=invis]" unless p_m.nil? %>
<%
    p_m=m
  end #methods
-%>

	// these are referenced from the inputs/outputs to complex types
	//putting outside the subgraph to show on another line
	//edge [ style=dashed]
	node [ style=none ]
<%
  code.methods.each do |m| #methods
-%>
<%= dot_links(m.inputs,"#{m.name}_inputs",defined,ignore) %>
<%= dot_links(m.outputs,"#{m.name}_outputs",defined,ignore) %>
<%
     m.faults.each do |f| #faults
	     #unless ignore[f.name].nil?
##for now, dont display the fault
#	     defined[f.name]=false if defined[f.name].nil?
-%>
//lets not show the fault references for now
//		<%=m.name%> -> <%=f.name%>
<%
       #end #ignore
     end #faults
  end #methods
-%>
  //references from method objects to detailed nodes
<%=
  dot_recurse(defined,ignore,code)
-%>
}
})
      @xsd_template=DotTemplate.new('xsd',171,%q{
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
})
    end
  end
end