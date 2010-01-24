#
# Based on PDF::HTMLDoc::View by vjt@openssl.it
# See <http://pastie.caboo.se/75997> (or <http://wiki.rubyonrails.org/rails/pages/HTMLDOC>)
#
class PDF::HTMLDoc::View
  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Partials

  def initialize(action_view)
    @action_view = action_view
    @controller = @action_view.controller
    # Include helper for controller in the view
    # FIXME: This will die if there is no helper
    self.class.class_eval "include ::#{@controller.class.to_s.sub(/Controller$/, 'Helper')}"
  end
  
  def self.compilable?
  	false
  end
  def compilable?
  	self.class.compilable?
  end

  def render(template, local_assigns = {})
    # Set default disposition
    #@controller.headers['Content-Disposition'] ||= 'inline'

    # Copy instance variables from controller to view
    @controller.instance_variables.each do |v|
      instance_variable_set(v, @controller.instance_variable_get(v))
    end

    # Evaluate the view
    content = (Rails::VERSION::MAJOR == 1) ? template : template.source
    markup = ERB.new(content).result(binding)

    # DEBUG
    puts "PDF::HTMLDoc::View: Writing view to file"
    outfile = File.join(RAILS_ROOT, 'tmp', "out.html")
    File.open(outfile, 'w') {|f| f.write(markup) }

    # Run the view through HTMLDoc and return the output, or raise errors if there are any
    pdf = PDF::HTMLDoc.new
    # don't know what this does
    pdf.set_option :path, Pathname.new(File.join(RAILS_ROOT, 'public')).realpath.to_s
    pdf << markup
    
    result = pdf.generate
    
    # DEBUG
    puts "PDF::HTMLDoc::View: Writing PDF to file"
    outfile = File.join(RAILS_ROOT, 'tmp', "out.pdf")
    File.open(outfile, 'w') {|f| f.write(result) }
    
    return result if result
    
    unless pdf.errors.empty?
      err = "Couldn't create PDF:\n"
      pdf.errors.map do |k,v|
        err << "#{k}: #{v}\n"
      end
      raise(err)
    end
  end
end