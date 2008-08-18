class XsdsController < ApplicationController           
  caches_page :index, :show, :meta, :table, :java #,:new

  before_filter :lookup_xsd, :except =>[:index,:new,:create] #:only=>%w()
  
  # GET /xsds
  # GET /xsds.xml
  def index
    @xsds = Xsd.find(:all)
    respond_to do |format|
      format.html { redirect_to :controller=>'wsdl'}
      format.xml  { render :xml => @wsdls.to_xml }
    end
  end

  # GET /xsds/1
  # GET /xsds/1.xml
  def show
    begin
      @code = @xsd.code
    rescue => e
      flash[:notice] = "Error in xsd: #{e}"
    end
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @xsd.to_xml }
      format.xsd  { render :template => 'xsds/show_xsd', :layout => false }
      format.dot  { render :inline=> Gen::DotGen.new.xsd_dot(@code,params[:ignore]) }
      format.png { png }
    end
  end

  # GET /xsds/1/java
  def java
#    if params[:layout] == "true"
#      layout=true 
#    else #default to inlined code
#      layout=false
#    end
#    
#    @code = @xsd.code(nil,false) #will raise exceptions - let it go through
    @code = @xsd.code #will raise exceptions - let it go through

    file_name=@xsd.zip_file_name
    tmp_zipfile="#{RAILS_ROOT}/tmp/#{file_name}"
    Gen::CodeGen.new.create_zip(@code,tmp_zipfile)
    send_file tmp_zipfile, :filename=>file_name, :type=>'application/zip'
    #File.delete(tmp_zipfile)
  end

  # GET /xsds/1.png (called from show)
  def png
    tmp_pngfile=Gen::PngGen.new.dot_to_png("#{@xsd.name}_xsd",Gen::DotGen.new.xsd_dot(@code,params[:ignore]))
    send_file tmp_pngfile, :type=>'image/png', :disposition=>'inline'
  end

  # GET /xsds/1/table.html
  def table
    begin
      @code = @xsd.code
    rescue => e
      #@code=@wsdl.contents
      flash[:notice] = "Error in xsd: #{e}"
    end
  end

  # GET /xsds/new
  def new
    @xsd = Xsd.new
    render :action => :edit
  end

  # GET /xsds/1/edit
  def edit
  end

  # POST /xsds
  # POST /xsds.xml
  def create
    @xsd = Xsd.new(params[:xsd])

    respond_to do |format|
      if @xsd.save
        flash[:notice] = 'Xsd was successfully created.'
        format.html { redirect_to xsd_url(@xsd) }
        format.xml  { head :created, :location => xsd_url(@xsd) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xsd.errors.to_xml }
      end
    end
  end

  # PUT /xsds/1
  # PUT /xsds/1.xml
  def update

    respond_to do |format|
      if @xsd.update_attributes(params[:xsd])
        flash[:notice] = 'Xsd was successfully updated.'
        format.html { redirect_to xsd_url(@xsd) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @xsd.errors.to_xml }
      end
    end
  end
            
  # DELETE /xsds/1
  # DELETE /xsds/1.xml
  # success was xsds_url
  def destroy
    @xsd.destroy

    respond_to do |format|
      format.html { redirect_to '/wsdl/' }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def lookup_xsd
    @xsd = Xsd.find_by_id(params[:id])
  end

  def expire_cache
    #expire all my instances
    expire_xsd(@xds)
    unless @xsd.nil? or @xsd.id.nil? or @xsd.wsdls.nil?
      @xsd.wsdls.each do |w|
    #    WsdlsController.expire_wsdl(w)
         expire_page(:controller=>'wsdl', :action => 'show', :id=>wsdl.name, :format => 'inline.wsdl')
      end
    end
    #move to wsdl?
    #aggrigate index page. (html version doesn't exist)
    expire_page(:controller=>'wsdl', :action => 'index')
    expire_page(:controller=>'xsds', :action => 'index', :format => 'xml')
  end

  def expire_xsd(xsd)
    expire_page(:controller=>'xsds', :action => 'show', :id=>xsd.id) #dot,png,html,...
    expire_page(:controller=>'xsds', :action => 'meta',  :format => 'html', :id=>xsd.id)
    expire_page(:controller=>'xsds', :action => 'table', :format => 'html', :id=>xsd.id)
    expire_page(:controller=>'xsds', :action => 'java',  :format => 'zip', :id=>xsd.id)
    expire_page(:controller=>'wsdl', :action => 'show', :id=>xsd.name, :format => 'xsd')
  end
end
