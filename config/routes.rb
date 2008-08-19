ActionController::Routing::Routes.draw do |map|
  map.resources :xsds, :member => { :java => :get, :meta => :get, :table => :get} 
#  do |xsds|
#    xsds.resources :classes
#  end

  #map.connect 'wsdls/:id.table.html', :controller => 'wsdls', :action=>'show',:format=>'table.html' 
  map.resources :wsdls, :member => { :java => :get, :meta => :get, :table => :get}, :collection => {:help=>:get}

  # /wsdl/identity.inline.wsdl
  # /wsdl/identity.wsdl
  # /wsdl/identy.xsd
  
  #/wsdls/1, /wsdls/1/edit
  #  map.connect 'wsdl/:id.inline.wsdl', :controller => 'wsdl', :action=>'wsdl',:external=>'false'
  #  map.connect 'wsdl/:id.:format', :controller => 'wsdl', :action=>'xsd',:requirements => {:format => /xsd/ }
  #  map.connect 'wsdl/:id.:format', :controller => 'wsdl', :action=>'wsdl',:requirements => {:format => /wsdl/ }
  map.connect 'wsdl/:id.inline.wsdl', :controller => 'wsdl', :action=>'show', :external=>'false', :format=>'wsdl'
  map.connect 'wsdl/:id.:format', :controller => 'wsdl', :action=>'show'
  map.connect 'wsdl/', :controller => 'wsdl'
  map.connect 'ping/:hostname', :controller => 'ping', :action => 'index'
  map.connect 'ping/', :controller => 'ping', :action => 'index'

  map.connect '', :controller => 'wsdl'
end
