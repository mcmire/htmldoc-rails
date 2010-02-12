require 'htmldoc_rails/htmldoc_ext'
require 'htmldoc_rails/controller'

module HtmldocRails
  class << self
    # @private
    def action_view
      ActionPack::VERSION::MAJOR == 1 ? ActionView::Base : ActionView::Template
    end
    def debug=(mode)
      @debug = mode
    end
    def debug?
      @debug
    end
  end
end

ActionController::Base.send(:include, HtmldocRails::Controller)
Mime::Type.register('application/pdf', :pdf)