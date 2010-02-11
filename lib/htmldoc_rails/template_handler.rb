# Based on PDF::HTMLDoc::View by Marcello Barnaba <vjt@openssl.it>
# http://gist.github.com/53906
# And also http://info.michael-simons.eu/2008/11/24/pdfwriter-and-ruby-on-rails-222/
#
module HtmldocRails
  class TemplateHandler < ActionView::TemplateHandlers::ERB
  
    def compile(template)
      # Run the view through ERB first
      code = super
      
      buffer_variable = ActionPack::VERSION::STRING >= "2.2" ? '@output_buffer' : '_erbout'
      
      # Now run it through HTMLDoc
      code += ";\n"
      code += <<-EOT
#puts "---------------------"
#puts "Output buffer:"
#puts "---------------------"
#puts #{buffer_variable}

pdf = PDF::HTMLDoc.new
# don't know what this does
pdf.set_option :path, Pathname.new(File.join(RAILS_ROOT, 'public')).realpath.to_s
pdf << #{buffer_variable}
result = pdf.generate

unless pdf.errors.empty?
  err = "Couldn't create PDF:\\n"
  pdf.errors.map do |k,v|
    err << "\#{k}: \#{v}\\n"
  end
  raise(err)
end

#{buffer_variable} = result
EOT

      code = <<EOT
begin
  #{code}
rescue => e
  puts "\#{e.class}: \#{e.message}"
  puts e.backtrace.join("\\n")
end
EOT
      
      #puts "---------------------"
      #puts "Code:"
      #puts "---------------------"
      #puts code
      
      code
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