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
#Protest::Utils::BacktraceFilter::ESCAPE_PATHS << %r|test/unit| << %r|matchy| << %r|mocha-protest-integration| << %r|actionpack|
Protest::Utils::BacktraceFilter::ESCAPE_PATHS.clear

#----

if ENV["AP_VERSION"]
  gem 'actionpack', "= #{ENV["AP_VERSION"]}"
end

require 'action_controller'

# Since ActionController::TestCase in 2.3.5 tries to require Mocha
# and replaces it with a stub on failure we have to save a reference
# to the current class and then replace the stub Mocha with the real Mocha
CurrentMocha = Mocha
require 'action_controller/test_case'
Object.const_set :Mocha, CurrentMocha

require 'action_controller/integration'
require 'action_view'
require 'action_pack/version'
require 'active_support/version'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))
RAILS_ENV = "test"

#logger = Logger.new(STDOUT)
#logger.level = Logger::DEBUG
#ActionController::Base.logger = logger

# Disable sessions so we don't get a 'key is required to write a cookie
# containing the session data' error
ActionController::Base.session_store = nil

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
    end
  end
end

require 'htmldoc'

#----

# This is only here so our template handler won't complain
module ApplicationHelper; end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action'
end

require 'htmldoc-rails'

# This has to be set after we require htmldoc-rails and consequently
# after rpdf is added to the template handlers, that way the Template objects
# have rpdf stored as the extension
ActionController::Base.view_paths = File.expand_path(File.dirname(__FILE__) + '/views')