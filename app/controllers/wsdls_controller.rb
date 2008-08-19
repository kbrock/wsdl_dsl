class WsdlsController < ApplicationController

  caches_page :index, :show, :meta, :table #, :java #,:new
  #help shouldn't be in here...
  caches_page :help
    
  before_filter :lookup_wsdl, :except =>[:index,:new,:create, :help] #:only=>%w()
  before_filter :expire_cache, :only=>%w(create destroy update)

  # GET /wsdls
  # GET /wsdls.xml
  def index
    respond_to do |format|
      format.html { redirect_to :controller=>'wsdl'}
      format.xml  { @wsdls = Wsdl.find(:all) ; render :xml => @wsdls.to_xml }
    end
  end

  # GET /wsdls/1
  def show
    begin
      @code = @wsdl.code
    rescue => e
      #@code=@wsdl.contents
      flash[:notice] = "Error in wsdl: #{e}"
    end
    respond_to do |format|
      format.html # show.rhtml
      format.wsdl { render :template => 'wsdls/show', :layout => false }
      format.dot  { render :inline=> Gen::DotGen.new.wsdl_dot(@code,params[:ignore]) }
      format.png { png }
    end
  end

  # GET /wsdls/1.png (called from show)
  def png
    tmp_pngfile=Gen::PngGen.new.dot_to_png("#{@wsdl.name}_wsdl",
                    Gen::DotGen.new.wsdl_dot(@code,params[:ignore]))
    send_file tmp_pngfile, :type=>'image/png', :disposition=>'inline'
    #File.delete(tmp_pngfile)
  end

  # GET /wsdls/1/javaa.zip
  def java
    #external means defaults to true, but otherwise false
    external = (params[:external]=='true') || (params[:external]==true)

    @code = @wsdl.code(nil,external) #will raise exceptions - let it go through

    file_name=@wsdl.zip_file_name
    tmp_zipfile="#{RAILS_ROOT}/tmp/#{file_name}"
    Gen::CodeGen.new.create_zip(@code,tmp_zipfile)
    send_file tmp_zipfile, :filename=>file_name, :type=>'application/zip'
    #File.delete(tmp_zipfile)
  end

  def table
    begin
      @code = @wsdl.code
    rescue => e
      #@code=@wsdl.contents
      flash[:notice] = "Error in wsdl: #{e}"
    end
  end
  
#  def meta
#  end

  # GET /wsdls/new
  def new
    @wsdl = Wsdl.new
    @wsdl.host='localhost'
    @wsdl.application='app'
    render :action => :edit
  end

  # GET /wsdls/1;edit
  def edit
  end

  # POST /wsdls
  # POST /wsdls.xml
  def create
    expire_page(:controller => 'wsdl', :action => 'show')
    @wsdl = Wsdl.new(params[:wsdl])

    respond_to do |format|
      if @wsdl.save
        flash[:notice] = 'Wsdl was successfully created.'
        format.html { redirect_to wsdl_url(@wsdl) }
        format.xml  { head :created, :location => wsdl_url(@wsdl) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wsdl.errors.to_xml }
      end
    end
  end

  # PUT /wsdls/1
  # PUT /wsdls/1.xml
  def update
    #ensure empty groups get cleared out
    if !params['wsdl']['xsd_ids']
      @wsdl.xsds.clear
    end

    respond_to do |format|
      if @wsdl.update_attributes(params[:wsdl])
        flash[:notice] = 'Wsdl was successfully updated.'
        format.html { redirect_to wsdl_url(@wsdl) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wsdl.errors.to_xml }
      end
    end
  end

  # DELETE /wsdls/1
  # DELETE /wsdls/1.xml
  # success was wsdls_url
  def destroy
    @wsdl.destroy

    respond_to do |format|
      format.html { redirect_to '/wsdl/' }
      format.xml  { head :ok }
    end
  end

  # GET /wsdls/help.html
  def help
  end

  protected
  
  def lookup_wsdl
#    @wsdl = Wsdl.find_by_name(params[:id])
    @wsdl = Wsdl.find(params[:id])
  end

  def expire_cache
    #expire all my instances
    unless @wsdl.nil? or @wsdl.id.nil?
      expire_wsdl(@wsdl)
    end
    #aggrigate index page. (html version doesn't exist)
    expire_page(:controller=>'wsdl', :action => 'index')
    expire_page(:controller=>'wsdls', :action => 'index', :format => 'xml')
  end

  def expire_wsdl(wsdl)
    expire_page(:controller=>'wsdls', :action => 'show', :id=>wsdl.id) #dot,png,html,...
    expire_page(:controller=>'wsdls', :action => 'meta',  :format => 'html', :id=>wsdl.id)
    expire_page(:controller=>'wsdls', :action => 'table', :format => 'html', :id=>wsdl.id)
    expire_page(:controller=>'wsdls', :action => 'java',  :format => 'zip', :id=>wsdl.id)

    expire_page(:controller=>'wsdl', :action => 'show', :id=>wsdl.name, :format => 'wsdl')
#    expire_page(:controller=>'wsdl', :action => 'show', :id=>wsdl.name, :format => 'inline.wsdl')
  end
end
