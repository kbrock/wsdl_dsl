# Be sure to restart your server when you modify this file

# ENV['RAILS_ENV'] ||= 'production'
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.gem "rubyzip"

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
