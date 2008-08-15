# Be sure to restart your server when you modify this file

# ENV['RAILS_ENV'] ||= 'production'
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "rubyzip"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_wsdls_session',
    :secret      => '2d787eddc7b481a685817405cf5ce06575d74b085d0b80d3348d0bf439b4b34b6e4114868f19f11c4c1e3b4053c26708400bb0f54728175c89057adfae010f71'
  }

  # config.action_controller.session_store = :active_record_store
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Add new inflection rules using the following format
  # (all these examples are active by default):
  # Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end

  # See Rails::Configuration for more options
  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register "text/plain", :txt
Mime::Type.register "application/xml", :wsdl
Mime::Type.register "application/xml", :xsd
Mime::Type.register "text/dot", :dot
#Mime::Type.register "text/plain", :java
Mime::Type.register "image/png", :png


# Include your application configuration below
require 'zip/zip'

DOT_CMD=['/opt/local/bin/dot','c:/Program Files/Graphviz2.16/bin/dot.exe'].select {|c|File.file?(c)}
raise "no dot command found" if DOT_CMD.nil?
