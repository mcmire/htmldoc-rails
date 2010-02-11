module HtmldocRails
  module Controller
    # Converts the given view to PDF and gives it to the browser. You can call
    # it like this:
    #
    #   render_pdf :controller => 'foo', :action => 'bar'
    #
    # or like this:
    #
    #   render_pdf :attachment => true,
    #     :url => { :controller => 'foo', :action => 'bar' },
    #     :htmldoc => { :top => 50 }
    #
    # Options are:
    #   :as => :inline
    #      Renders the PDF in the browser. (default)
    #   :as => :attachment
    #      Pops up a download box when the page loads.
    #   :filename => "..."
    #      The default filename for the file being downloaded, assuming :as =>
    #      :attachment.
    #   :url => {...} | "..."
    #      The url hash/string that points to the view to render.
    #   :htmldoc => {...}
    #      Options that will be passed to HTMLDoc when the PDF is rendered.
    #
    # You can also affect the disposition at runtime by appending
    # ?as=attachment|inline to the URL.
    #
    def render_pdf(options)
      filename = options.delete(:filename)
      disposition = (options.delete(:as) || params[:as] || :inline).to_sym
      htmldoc_options = options.delete(:htmldoc) || {}
      render_options = options.merge(options.delete(:url) || {})
      if !render_options.include?(:layout)
        render_options[:layout] = false
      end
      #format = (params[:format] || :rpdf).to_sym
      #render_options[:format] = format
    
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
    
      # run view through PDF::HTMLDoc::View
      pdf_data = PDF::HTMLDoc.with_options(htmldoc_options) { render_to_string(render_options) }
      unless pdf_data.blank?
        send_data(pdf_data, send_data_options) 
      else
        render :text => "HTMLDoc had trouble parsing the HTML to create the PDF."
      end
    end
  
    # Converts the given view to PDF and stores the PDF to the given file. You
    # can call it like this:
    #
    #   render_pdf_to_file 'foo.pdf', :action => 'blah'
    #
    # or this:
    #
    #   render_pdf_to_file 'foo.pdf', { :action => 'blah' }, { :top => 50 }
    #
    # Arguments are:
    #
    # 1. The outfile
    # 2. The url hash/string that points to the view to render
    # 3. Options to pass to HTMLDoc (optional)
    #
    def render_pdf_to_file(filename, url_for_options, htmldoc_options={})
      if !url_for_options.include?(:layout)
        url_for_options[:layout] = false
      end
      headers["Content-Disposition"] = "inline"
      pdf_data = PDF::HTMLDoc.with_options(htmldoc_options) { render_to_string(url_for_options) }
      File.open(filename, 'w') {|f| f.write(pdf_data) }
    end

  private
    def content_type
      Mime::Type.lookup_by_extension('pdf')
    end
    
  end
end