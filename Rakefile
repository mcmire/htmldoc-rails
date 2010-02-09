require 'rubygems'
require 'rake'

require File.dirname(__FILE__) + "/lib/mcmire/render_htmldoc_pdf/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version = Mcmire::RenderHtmldocPdf::VERSION
    gem.name = "render_htmldoc_pdf"
    gem.summary = %Q{Generate PDFs from your Rails views using HTMLDoc}
    gem.description = %Q{Generate PDFs from your Rails views using HTMLDoc}
    gem.email = "elliot.winkler@gmail.com"
    gem.homepage = "http://github.com/mcmire/render_htmldoc_pdf"
    gem.authors = ["Elliot Winkler"]
    gem.add_dependency "htmldoc"
    unless ENV["AP_VERSION"]
      gem.add_dependency "actionpack", "< 3.0"
    end
    gem.add_development_dependency "mcmire-protest"
    gem.add_development_dependency "mcmire-matchy"
    gem.add_development_dependency "mcmire-mocha"
    gem.add_development_dependency "mocha-protest-integration"
    #gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :check_platform do
  if RUBY_PLATFORM !~ /darwin|linux/
    warn <<-EOT
Sorry, you can only run the tests if you're on Mac or Linux. This is because the
tests use the `file` command to detect file type, but to my knowledge this
command is only available on Mac or Linux.
EOT
    exit 1
  end
end

task :test => [:check_platform, :check_dependencies, :"check_dependencies:development"]

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end