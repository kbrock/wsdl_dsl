module Gen
  module CodeTemplate
    attr_accessor :name,:src,:template

    def compile(name, offset, src)
      @name=name
      if(src==nil)
        @src=offset
        @offset=0
      else
        @src=src
        @offset=offset
      end
      @template=ERB.new(@src,nil,"-")
    end
  
    ## obj is the object, objname is the filename / obj + ext
    def run_template(binding)
      begin
        @template.result(binding)
      rescue => e
        e.backtrace[1] =~ /\(erb\):([0-9]+)/
        line_no=$1.to_i
        raise RuntimeError, "error in #{@name}:line #{line_no+@offset} #{e}\n #{@src.split(/\n/)[line_no-1]} ",
          e.backtrace
      end
    end
  end
end