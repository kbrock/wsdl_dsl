# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #exact will link to this exact location. unfortunatly it ends up with extra lines. so this is disabled for now
  @exact=false
  # syntax hilight the dsl / ruby code  
  def show_ruby(str)
    #TODO: use syntax
    # http://blog.wolfman.com/articles/2006/05/26/howto-format-ruby-code-for-blogs
    str2=str
    str2.gsub!(/('[^']*')/) {"<span class='quote'>#{$1}</span>"}
    str2.gsub!(/(#.*)\n/) { "<span class='comment'>#{$1}</span>" }
    str2.gsub!(/(string|integer|boolean|double|float|dateTime|date)/) {"<span class='data'>#{$1}</span>"}
    str2.gsub!(/(^| )(type|do|end|method|fault|false|true)/) {"#{$1}<span class='keyword'>#{$2}</span>#{$3}"}
    str2.gsub!(/ (:[^=]*)/) {" <span class='option'>#{$1}</span>"}    
    str2
  end
  
  ##
  def dot_struct(s,name=nil,label=nil, defined=nil)
    defined[s.name]=true if not defined.nil?
    rslts=[]
    rslts << "#{name||s.name} [label=\"{#{label||name||s.name}#{'|' unless @exact}"
    qualifier=""
    s.fields.each do |f| #fields in the method
      qualifier = "|<#{f.name}> " if @exact
      fname=f.name
      fname="(#{fname})" if f.optional? and not f.output? and not f.array?
      fname="#{fname}[]" if f.array?
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
