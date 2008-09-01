require 'htmldoc' # gem

require 'premiere/render_htmldoc_pdf/pdf_htmldoc_ext'
require 'premiere/render_htmldoc_pdf/mime_ext'
require 'premiere/render_htmldoc_pdf/pdf_htmldoc_view'
require 'premiere/render_htmldoc_pdf/controller'

ActionController::Base.send(:include, Premiere::RenderHtmldocPdf::Controller)
