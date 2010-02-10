require 'helper'

class RenderPdfController < ActionController::Base
  def default
    render_pdf :action => 'doc.rpdf'
    #render_pdf :file => File.dirname(__FILE__) + '/views/render_pdf/doc.rpdf'
  end
  def default_with_layout
    render_pdf :action => 'doc.rpdf', :layout => "layout"
  end
  def download
    render_pdf :url => {:action => 'doc.rpdf'}, :as => :attachment
  end
  def download_with_filename
    render_pdf :url => {:action => 'doc.rpdf'}, :as => :attachment, :filename => "foo.pdf"
  end
  def with_just_filename
    render_pdf :url => {:action => 'doc.rpdf'}, :filename => "foo.pdf"
  end
  def inline_with_filename
    render_pdf :url => {:action => 'doc.rpdf'}, :as => :inline, :filename => "foo.pdf"
  end
  def with_htmldoc_options
    render_pdf :action => 'doc.rpdf', :htmldoc => {:top => 10, :left => 10}
  end
  def with_no_url
    render_pdf
  end
end

module RenderPdfHelper; end

# AV::Template#initialize("/full/path/to/render_pdf/doc.rpdf")
# - AV::Template#split("/full/path/to/render_pdf/doc.rpdf")
#   - AV::Template#valid_extension?("rpdf") #=> [base_path = "/full/path/to/render_pdf/", name = "doc", format = nil, extension = "rpdf"]
#
# AC::Base#render(options = {:action => 'doc.rpdf', :layout => false}, extra_options = {}):
# - AC::Base#pick_layout(options = {:action => 'doc.rpdf', :layout => false}) #=> nil
# - AC::Base#default_template_name(action_name = "doc.rpdf") #=> "render_pdf/doc.rpdf"
# - AC::Base#render_for_file(action_name = "render_pdf/doc.rpdf", status = nil, layout = nil, locals = {})
#   - AV::Base#render(options = {:file => "render_pdf/doc.rpdf", :locals => {}, :layout => nil}, local_assigns = {})
#     - AV::Base#_pick_template(template_path = "render_pdf/doc.rpdf") #=> AV::Template.new("/full/path/to/render_pdf/doc.rpdf")
#     - AV::Template#render_template(view, locals = {})
#       - AV::Template#render(view, locals = {})  # in Renderable
#         - AV::Template#compile(locals = {})  # in Renderable
#           - AV::Template#recompile?(render_symbol) #=> true  # in Renderable
#             - AV::PathSet::Path.eager_load_templates? #=> false since config.cache_classes is false
#           - AV::Template#compile!(render_symbol, local_assigns = {})  # in Renderable
#             - AV::Template#compiled_source #=> "the template"  # Renderable
#               - AV::Template#handler
#                 - AV::Template.handler_class_for_extension(extension = "rpdf") #=> should return PDF::HTMLDoc::View??  # in TemplateHandlers
#               - PDF::HTMLDoc::View#call #=> "PDF::HTMLDoc::View.new(self).render(template, local_assigns)"
#             - PDF::HTMLDoc::View.new(view).render(template, local_assigns = {})

Protest::Rails::FunctionalTestCase.describe("render_pdf") do
  self.controller_class = RenderPdfController
  
  def visit(url, options={})
    get(url, options)
    #puts "Headers:"
    #pp :headers => response.headers
    #puts "Response body:"
    #puts response.body unless response.success?
  end
  
  test "converts a view into a PDF with the right content type" do
    visit :default
    response.content_type.should == 'application/pdf'
    tempfile = Tempfile.new("test_render_htmldoc_pdf")
    tempfile.write(response.body)
    `file -Ib "#{tempfile.path}"`.chomp.should == "application/pdf"
  end
  test "returns an error if the PDF file couldn't be generated for some reason" do
    controller.stubs(:render_to_string).returns(nil)
    visit :default
    response.body.should =~ /HTMLDoc had trouble parsing the HTML to create the PDF/
  end
  test ":url option is required" do
    lambda { visit :with_no_url }.should raise_error
  end
  
  test "the PDF file is rendered with no layout by default" do
    controller.stubs(:render_to_string)
    visit :default
    controller.should have_received(:render_to_string).with(has_entry(:layout, false))
  end
  test "the PDF file is rendered with a layout if one was specified" do
    controller.stubs(:render_to_string)
    visit :default_with_layout
    controller.should have_received(:render_to_string).with(has_entry(:layout, "layout"))
  end
  
  test "renders the PDF in the browser by default" do
    visit :default
    response.headers["Content-Disposition"].should == "inline"
  end
  test ":as => :attachment option gives the user a download box" do
    visit :download
    response.headers["Content-Disposition"].should == "attachment"
  end
  test ":filename option when disposition is attachment pre-sets the filename that the user will download the PDF as" do
    visit :download_with_filename
    response.headers["Content-Disposition"].should == 'attachment; filename="foo.pdf"'
  end
  test ":filename option without disposition does not auto-set disposition to attachment" do
    visit :with_just_filename
    response.headers["Content-Disposition"].should == 'inline; filename="foo.pdf"'
  end
  test ":filename option when disposition is inline sets filename" do
    visit :inline_with_filename
    response.headers["Content-Disposition"].should == 'inline; filename="foo.pdf"'
  end
  test "?as=attachment in the querystring gives the user a download box" do
    visit :download, :as => "attachment"
    response.headers["Content-Disposition"].should == "attachment"
  end
  test "?as=inline in the querystring renders the PDF in the browser" do
    visit :default, :as => "inline"
    #response.success?.should == true
    response.headers["Content-Disposition"].should == "inline"
  end
  
  test "sends headers to ensure that the PDF file isn't cached" do
    visit :default
    response.headers["Pragma"].should == "no-cache"
    response.headers["Cache-Control"].should == 'no-cache, must-revalidate'
  end
  test "doesn't ensure PDF file isn't cached on IE" do
    request.env['HTTP_USER_AGENT'] = "msie"
    visit :default
    response.headers["Pragma"].should == ""
    response.headers["Cache-Control"].should == ""
  end
  
  test "forwards :htmldoc options to HTMLDoc" do
    PDF::HTMLDoc.stubs(:with_options)
    visit :with_htmldoc_options
    PDF::HTMLDoc.should have_received(:with_options).with(:left => 10, :top => 10)
  end
  
end