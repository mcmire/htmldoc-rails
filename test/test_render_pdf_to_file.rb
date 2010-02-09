require 'helper'

class RenderPdfToFileController < ActionController::Base
  def default
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", :action => 'doc.rpdf'
    render :nothing => true
  end
  def default_with_layout
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", :action => 'doc.rpdf', :layout => "layout"
    render :nothing => true
  end
  def with_htmldoc_options
    render_pdf_to_file "/tmp/htmldoc-rails.test.pdf", {:action => 'doc.rpdf'}, :top => 10, :left => 10
    render :nothing => true
  end
end

module RenderPdfToFileHelper; end

Protest::Rails::FunctionalTestCase.describe("render_pdf_to_file") do
  self.controller_class = RenderPdfToFileController
  
  test "writes the rendered PDF to the given file" do
    visit :default
    File.exists?("/tmp/htmldoc-rails.test.pdf").should == true
  end
  test "sends the PDF straight to the browser" do
    visit :default
    response.headers["Content-Disposition"].should == "inline"
  end
  test "forwards htmldoc options straight to HTMLDoc" do
    PDF::HTMLDoc.stubs(:with_options)
    visit :with_htmldoc_options
    PDF::HTMLDoc.should have_received(:with_options).with(:left => 10, :top => 10)
  end
  test "renders the PDF in no layout by default" do
    controller.stubs(:render_to_string)
    visit :default
    controller.should have_received(:render_to_string).with(has_entry(:layout, false))
  end
  test "renders the PDF in the layout that's specified" do
    controller.stubs(:render_to_string)
    visit :default_with_layout
    controller.should have_received(:render_to_string).with(has_entry(:layout, "layout"))
  end
end