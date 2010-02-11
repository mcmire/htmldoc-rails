require 'htmldoc_rails/htmldoc_ext'
require 'htmldoc_rails/controller'
require 'htmldoc_rails/template_handler'

module HtmldocRails
  class << self
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
HtmldocRails.action_view.register_template_handler(:rpdf, HtmldocRails::TemplateHandler)
Mime::Type.register('application/pdf', :pdf)