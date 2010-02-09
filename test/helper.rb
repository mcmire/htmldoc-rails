require 'rubygems'

require 'pp'

gem 'mcmire-protest'
require 'protest'
gem 'mcmire-mocha'
require 'mocha'
# This must be required before matchy since matchy patches
# the current test case's #run method, however mocha-protest-integration
# completely overrides it
require 'mocha-protest-integration'
#gem 'mcmire-matchy'
$:.unshift "/Users/elliot/code/github/forks/matchy/lib"
require 'matchy'

# Matchy/Protest integration
Matchy.adapter :protest, "Protest" do
  def assertions_module; Test::Unit::Assertions; end
  def test_case_class; Protest::TestCase; end
  def assertion_failed_error; Protest::AssertionFailed; end
end
Matchy.use(:protest)

Protest.report_with :documentation
Protest::Utils::BacktraceFilter::ESCAPE_PATHS << %r|test/unit| << %r|matchy| << %r|mocha-protest-integration| << %r|actionpack|
#Protest::Utils::BacktraceFilter::ESCAPE_PATHS.clear

#----

if ENV["AP_VERSION"]
  gem 'actionpack', "= #{ENV["AP_VERSION"]}"
end
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/integration'
require 'action_view'
require 'action_pack/version'
require 'active_support/version'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

# Disable sessions so we don't get a 'key is required to write a cookie
# containing the session data' error
ActionController::Base.session_store = nil

ActionController::Base.view_paths = File.dirname(__FILE__) + '/views'

# Copied from Protest::Rails, customized to remove webrat and transactions,
# made compatible with Rails 2.1
=begin
module Protest
  module Rails
    class TestCase < ::Protest::TestCase
      #include ::Test::Unit::Assertions
      #if ::ActiveSupport::VERSION::STRING != "2.1.2"
      #  include ::ActiveSupport::Testing::Assertions
      #end
      #%w(response selector tag dom routing model).each do |kind|
      #  require "action_controller/assertions/#{kind}_assertions"
      #  include ::ActionController::Assertions.const_get("#{kind.camelize}Assertions")
      #end
      include ::ActionController::Integration::Runner
    end
  end
  class << self
    def context(description, &block)
      Rails::TestCase.context(description, &block)
    end
    alias_method :describe, :context
  end
end
=end

module Protest
  module Rails
    # Copied from ActionController::TestCase
    class FunctionalTestCase < ::Protest::TestCase
      include ActionController::TestProcess
      
      # When the request.remote_addr remains the default for testing, which is 0.0.0.0, the exception is simply raised inline
      # (bystepping the regular exception handling from rescue_action). If the request.remote_addr is anything else, the regular
      # rescue_action process takes place. This means you can test your rescue_action code by setting remote_addr to something else
      # than 0.0.0.0.
      #
      # The exception is stored in the exception accessor for further inspection.
      module RaiseActionExceptions
        attr_accessor :exception

        def rescue_action(e)
          self.exception = e

          if request.remote_addr == "0.0.0.0"
            raise(e)
          else
            super(e)
          end
        end
      end

      @@controller_class = nil

      class << self
        def controller_class=(new_class)
          prepare_controller_class(new_class)
          write_inheritable_attribute(:controller_class, new_class)
        end

        def controller_class
          if current_controller_class = read_inheritable_attribute(:controller_class)
            current_controller_class
          end
        end

        def prepare_controller_class(new_class)
          new_class.send :include, RaiseActionExceptions
        end
      end
      
      attr_reader :controller, :request, :response
      
      setup do
        @controller = self.class.controller_class.new
        @controller.request = @request = ActionController::TestRequest.new
        @response = ActionController::TestResponse.new
      end

      # Cause the action to be rescued according to the regular rules for rescue_action when the visitor is not local
      #def rescue_action_in_public!
      #  @request.remote_addr = '208.77.188.166' # example.com
      #end
    end
  end
end

require 'htmldoc'

#----

# This is only here so PDF::HTMLDoc::View won't complain
module ApplicationHelper; end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action'
end

Protest::Rails::FunctionalTestCase.class_eval do
  def visit(url, options={})
    get(url, options)
    #puts "Headers:"
    #pp :headers => response.headers
    #puts "Response body:"
    #puts response.body unless response.success?
  end
end

require 'mcmire/render_htmldoc_pdf'