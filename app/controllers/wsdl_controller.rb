class WsdlController < ApplicationController 

  caches_page :index, :show

  def index
    @wsdls=Wsdl.find(:all)
    @xsds=Xsd.find(:all)
  end

#  #TODO: for both, lookup mime_type :mime_type => Mime::Type["text/calendar"]

  def show
    if params[:format] == 'wsdl' or params[:format] == 'inline.wsdl'
      wsdl
    elsif params[:format]=='xsd'
      xsd
    else
      raise "unknown format #{params[:format]}"
    end  
  end

  def wsdl
    #wsdl is external: when .inline is in url, then embed the wsdl
    external = params[:external]!='false' && params[:external]!=false
    
    @wsdl=Wsdl.find_by_name(params[:id])
    @code = @wsdl.code nil,external
    render :template => 'wsdls/show_wsdl', :layout => false ,:content_type=>"application/xml"
  end

  def xsd
    @xsd=Xsd.find_by_name(params[:id])
    @code = @xsd.code
    render :template => 'xsds/show_xsd', :layout => false, :content_type=>"application/xml"
  end
end