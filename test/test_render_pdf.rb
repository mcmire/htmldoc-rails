require 'helper'

class RenderPdfController < ActionController::Base
  def default
    render_pdf :action => 'doc.html.erb'
  end
  def default_with_layout
    render_pdf :action => 'doc.html.erb', :layout => "layout"
  end
  def download
    render_pdf :url => {:action => 'doc.html.erb'}, :as => :attachment
  end
  def download_with_filename
    render_pdf :url => {:action => 'doc.html.erb'}, :as => :attachment, :filename => "foo.pdf"
  end
  def with_just_filename
    render_pdf :url => {:action => 'doc.html.erb'}, :filename => "foo.pdf"
  end
  def inline_with_filename
    render_pdf :url => {:action => 'doc.html.erb'}, :as => :inline, :filename => "foo.pdf"
  end
  def with_htmldoc_options
    render_pdf :action => 'doc.html.erb', :htmldoc => {:top => 10, :left => 10}
  end
  def with_no_url
    render_pdf
  end
  def partial
    render_pdf :action => 'doc_with_partial.html.erb'
  end
  def responder
    respond_to do |wants|
      wants.html { render :text => "HTML" }
      wants.pdf { render_pdf :action => 'doc.html.erb' }
    end
  end
  def no_arguments
    render_pdf
  end
  def rpdf
    render_pdf :action => 'doc.rpdf'
  end
end

module RenderPdfHelper; end

Protest::Rails::FunctionalTestCase.describe("render_pdf") do
  self.controller_class = RenderPdfController
  
  def visit(url, options={})
    get(url, options)
    #puts "Headers:"
    #pp :headers => response.headers
    #puts "Response body:"
    #puts response.body unless response.success?
  end
  
  def should_render_a_pdf
    response.content_type.should == 'application/pdf'
    tempfile = Tempfile.new("test_htmldoc_rails")
    tempfile.write(response.body)
    `file -Ib "#{tempfile.path}"`.chomp.should == "application/pdf"
  end
  
  test "converts a view into a PDF with the right content type" do
    visit :default
    should_render_a_pdf
  end
  test "returns an error if the PDF file couldn't be generated for some reason" do
    PDF::HTMLDoc.stubs(:create).returns(nil)
    visit :default
    response.body.should =~ /HTMLDoc had trouble parsing the HTML to create the PDF/
  end
  test ":url option is required" do
    lambda { visit :with_no_url }.should raise_error
  end
  
  test "the PDF file is rendered with no layout by default" do
    controller.stubs(:render_to_string).returns("")
    visit :default
    controller.should have_received(:render_to_string).with(has_entry(:layout, false))
  end
  test "the PDF file is rendered with a layout if one was specified" do
    controller.stubs(:render_to_string).returns("")
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
  
  test "forwards :htmldoc options straight to HTMLDoc" do
    pdf = PDF::HTMLDoc.new
    pdf.stubs(:set_option)
    PDF::HTMLDoc.stubs(:create).returns("").yields(pdf)
    visit :with_htmldoc_options
    pdf.should have_received(:set_option).with(:left, 10)
    pdf.should have_received(:set_option).with(:top, 10)
  end
  
  test "rendering a partial within a view works" do
    visit :partial
    should_render_a_pdf
  end
  
  test "rendering a view in a responder works" do
    request.accept = "application/pdf"
    visit :responder
    should_render_a_pdf
  end
  
  test "renders a file named after the action if passed no arguments" do
    visit :no_arguments
    should_render_a_pdf
  end
  
end