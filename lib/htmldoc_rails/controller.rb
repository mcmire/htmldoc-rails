module HtmldocRails
  module Controller
    # Runs the given view through HTMLDoc and sends the generated PDF data back
    # to the browser.
    #
    # @param [Hash] options Various options
    # @option options [Hash, String] :url (nil) The hash/url that represents which
    #   view you want to render. Passed straight to <tt>render()</tt>.
    # @option options [Symbol] :as (:inline) The disposition; <tt>:inline</tt>
    #   renders the PDF in the browser, <tt>:attachment</tt> pops up a download
    #   box when the page loads. You can also set the disposition at runtime
    #   by appending <tt>?as=attachment|inline</tt> to the URL.
    # @option options [String] :filename (nil) The default filename for the file being
    #   downloaded, assuming <tt>:as => :attachment</tt>.
    # @option options [Hash] :htmldoc ({}) Options that will be passed to HTMLDoc
    #   when the PDF is rendered.
    #
    # @example Rendering default view of action as PDF
    #   render_pdf
    # @example Rendering a specific view as PDF
    #   render_pdf :action => 'bar'
    # @example Set a top-margin of 50px in the PDF and force a download box when the page loads
    #   render_pdf :action => "bar", :as => :attachment, :htmldoc => { :top => 50 }
    #
    def render_pdf(options={})
      filename = options.delete(:filename)
      disposition = (options.delete(:as) || params[:as] || :inline).to_sym
      htmldoc_options = options.delete(:htmldoc) || {}
      render_options = options.merge(options.delete(:url) || {})
      if !render_options.include?(:layout)
        render_options[:layout] = false
      end
    
      send_data_options = { :type => content_type }
      send_data_options[:filename] = filename if filename
      send_data_options[:disposition] = (disposition == :attachment) ? 'attachment' : 'inline'
    
      # Make sure that the rendered PDF isn't cached
      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = ''
        headers['Cache-Control'] = ''
      else
        headers['Pragma'] = 'no-cache'
        headers['Cache-Control'] = 'no-cache, must-revalidate'
      end
    
      # Run view through PDF::HTMLDoc::View
      html_content = render_to_string(render_options)
      pdf_data = run_through_htmldoc(html_content, htmldoc_options)
      unless pdf_data.blank?
        send_data(pdf_data, send_data_options) 
      else
        render :text => "HTMLDoc had trouble parsing the HTML to create the PDF."
      end
    end
  
    # Runs the given view through HTMLDoc and writes the generated PDF data
    # to the file of your choice.
    #
    # @param [String] filename The outfile
    # @param [Hash, String] render_options The hash/url that represents which
    #   view you want to render. Passed straight to <tt>render()</tt>.
    # @param [Hash] htmldoc_options Options that will be passed to HTMLDoc
    #   when the PDF is rendered.
    #
    # @example Render the 'blah' view to 'foo.pdf'
    #   render_pdf_to_file 'foo.pdf', :action => 'blah'
    # @example Same thing, but set a top-margin of 50px in the PDF
    #   render_pdf_to_file 'foo.pdf', { :action => 'blah' }, { :top => 50 }
    #
    def render_pdf_to_file(filename, render_options={}, htmldoc_options={})
      if !render_options.include?(:layout)
        render_options[:layout] = false
      end
      headers["Content-Disposition"] = "inline"
      html_content = render_to_string(render_options)
      pdf_data = run_through_htmldoc(html_content, htmldoc_options)
      File.open(filename, 'w') {|f| f.write(pdf_data) }
    end

  private
    def run_through_htmldoc(content, htmldoc_options)
      PDF::HTMLDoc.create do |pdf|
        PDF::HTMLDoc::DEFAULT_OPTIONS.merge(htmldoc_options).each do |name, value|
          pdf.set_option(name, value)
        end
        # don't know what this does??
        pdf.set_option :path, Pathname.new(File.join(RAILS_ROOT, 'public')).realpath.to_s
        pdf << content
      end
    end
  
    def content_type
      Mime::Type.lookup_by_extension('pdf')
    end
  end
end