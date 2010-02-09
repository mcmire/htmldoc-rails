require 'mcmire/render_htmldoc_pdf/controller'
require 'mcmire/render_htmldoc_pdf/mime_ext'
require 'mcmire/render_htmldoc_pdf/pdf_htmldoc_ext'
require 'mcmire/render_htmldoc_pdf/pdf_htmldoc_view'

module Mcmire
  module RenderHtmldocPdf
    def self.action_view
      ActionPack::VERSION::MAJOR == 1 ? ActionView::Base : ActionView::Template
    end
  end
end

ActionController::Base.send(:include, Mcmire::RenderHtmldocPdf::Controller)

unless Mime.const_defined?(:PDF) || Mime::Type.lookup('application/pdf')
  Mime::Type.register('application/pdf', :pdf)
end

Mcmire::RenderHtmldocPdf.action_view.register_template_handler('rpdf', PDF::HTMLDoc::View)
