module PDF
  class HTMLDoc
    @@basic_options << :top    unless @@basic_options.include?(:top)
    @@basic_options << :bottom unless @@basic_options.include?(:bottom)
    @@all_options = @@basic_options + @@extra_options

    # Set some sensible defaults
    DEFAULT_OPTIONS = {
      :bodycolor => 'white', :toc => false, :portrait => true, :continuous => true, :footer => '...', :header => '...',
      :links => false, :webpage => true, :left => '50', :right => '50', :top => '90', :size => 'Letter'
    }
    @@instance_options = {}
    class << self
      # Temporarily set options that will be passed to htmldoc
      # You should not attempt to nest calls to with_options as inner levels will overwrite outer levels!!
      def with_options(options)
        @@instance_options = merge_options(DEFAULT_OPTIONS, options)
        ret = yield
        @@instance_options = {}
        ret
      end
      private
      def merge_options(options1, options2)
        if options2.include?(:landscape)
          options1 = options1.reject { |key,| key == :portrait }
        elsif options2.include?(:portrait)
          options1 = options1.reject { |key,| key == :landscape }
        end
        options1.merge(options2)
      end
    end

    alias_method :old_initialize, :initialize
    def initialize(format=PDF)
      old_initialize(format)
      puts "HTMLDoc options: #{@@instance_options.inspect}"
      @@instance_options.each {|option, value| set_option(option, value) }
    end

    def self.create(format = PDF, &block)
      pdf = HTMLDoc.new(format)
      puts "HTMLDoc options: #{@@instance_options.inspect}"
      @@instance_options.each {|option, value| set_option(option, value) }
      if block_given?
        yield pdf
        pdf.generate
      end
    end
  end
end
