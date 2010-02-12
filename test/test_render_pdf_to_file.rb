require 'helper'

class RenderPdfToFileController < ActionController::Base
  def default
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", :action => 'doc.html.erb'
    render :nothing => true
  end
  def default_with_layout
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", :action => 'doc.html.erb', :layout => "layout"
    render :nothing => true
  end
  def with_htmldoc_options
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", {:action => 'doc.html.erb'}, :top => 10, :left => 10
    render :nothing => true
  end
  def partial
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", :action => 'doc_with_partial.html.erb'
    render :nothing => true
  end
  def no_arguments
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf"
    render :nothing => true
  end
end

module RenderPdfToFileHelper; end

Protest::Rails::FunctionalTestCase.describe("render_pdf_to_file") do
  self.controller_class = RenderPdfToFileController
  
  def visit(url, options={})
    get(url, options)
    #puts "Headers:"
    #pp :headers => response.headers
    #puts "Response body:"
    #puts response.body unless response.success?
  end
  
  def should_render_a_pdf
    File.exists?("/tmp/htmldoc-rails.test.pdf").should == true
    `file -Ib "/tmp/htmldoc-rails.test.pdf"`.chomp.should == "application/pdf"
  end
  
  test "writes the rendered PDF to the given file" do
    visit :default
    should_render_a_pdf
  end
  test "sends the PDF straight to the browser" do
    visit :default
    response.headers["Content-Disposition"].should == "inline"
  end
  test "forwards :htmldoc options straight to HTMLDoc" do
    pdf = PDF::HTMLDoc.new
    pdf.stubs(:set_option)
    PDF::HTMLDoc.stubs(:create).returns("").yields(pdf)
    visit :with_htmldoc_options
    pdf.should have_received(:set_option).with(:left, 10)
    pdf.should have_received(:set_option).with(:top, 10)
  end
  test "renders the PDF in no layout by default" do
    controller.stubs(:render_to_string).returns("")
    visit :default
    controller.should have_received(:render_to_string).with(has_entry(:layout, false))
  end
  test "renders the PDF in the layout that's specified" do
    controller.stubs(:render_to_string).returns("")
    visit :default_with_layout
    controller.should have_received(:render_to_string).with(has_entry(:layout, "layout"))
  end
  test "rendering a partial within a view works" do
    visit :partial
    should_render_a_pdf
  end
  test "renders a file named after the action if passed no arguments" do
    visit :no_arguments
    should_render_a_pdf
  end
end