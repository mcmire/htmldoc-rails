# Based on PDF::HTMLDoc::View by Marcello Barnaba <vjt@openssl.it>
# http://gist.github.com/53906
# And also http://info.michael-simons.eu/2008/11/24/pdfwriter-and-ruby-on-rails-222/
#
module HtmldocRails
  class TemplateHandler < ActionView::TemplateHandler
    include ApplicationHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
  
    def self.call(template)
      "HtmldocRails::TemplateHandler.new(self).render(template, local_assigns)"
    end

    def initialize(action_view)
      @action_view = action_view
      @controller = @action_view.controller
    end
  
    def render(template, local_assigns={})
      # Evaluate the view
      content = (ActionPack::VERSION::MAJOR == 1) ? template : template.source
      markup = ERB.new(content).result(binding)

      if HtmldocRails.debug?
        write_file(markup, "out.html", "Writing view to file")
      end

      # Run the view through HTMLDoc and return the output, or raise errors if there are any
      pdf = PDF::HTMLDoc.new
      # don't know what this does
      pdf.set_option :path, Pathname.new(File.join(RAILS_ROOT, 'public')).realpath.to_s
      pdf << markup
    
      result = pdf.generate
    
      if HtmldocRails.debug?
        write_file(result, "out.pdf", "Writing PDF to file")
      end
    
      return result if result
    
      unless pdf.errors.empty?
        err = "Couldn't create PDF:\n"
        pdf.errors.map do |k,v|
          err << "#{k}: #{v}\n"
        end
        raise(err)
      end
    end
    
  private
    def write_file(content, filename, msg)
      RAILS_DEFAULT_LOGGER.debug "htmldoc-rails: #{msg}"
      dir = "/tmp/htmldoc-rails"
      FileUtils.mkdir_p(dir)
      outfile = File.join(dir, filename)
      File.open(outfile, 'w') {|f| f.write(content) }
    end
  end
end