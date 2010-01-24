require 'htmldoc' # gem

lib = File.dirname(__FILE__) + "/lib/mcmire/render_htmldoc_pdf"
%w(mime_ext pdf_htmldoc_ext pdf_htmldoc_view controller).each {|file| require File.join(lib, file) }

ActionController::Base.send(:include, Mcmire::RenderHtmldocPdf::Controller)

unless Mime.const_defined?(:PDF) || Mime::Type.lookup('application/pdf')
  Mime::Type.register('application/pdf', :pdf)
end

if Rails::VERSION::MAJOR == 1
  ActionView::Base
else 
  ActionView::Template
end.register_template_handler 'rpdf', PDF::HTMLDoc::View
