require 'pathname'

proj_dir = File.expand_path(File.dirname(__FILE__) + '/..')
lib_dir  = "#{proj_dir}/lib"
test_dir = "#{proj_dir}/test"

$:.unshift(lib_dir, test_dir)

files = Dir["#{test_dir}/test_*.rb"]

pids = []

%w(2.1.2 2.2.3 2.3.5).each do |version|
  (class << $stdout; self; end).class_eval <<-EOT, __FILE__, __LINE__
    def puts(*str)
      str = str.flatten
      str[0] = "#{version})) \#{str[0]}"
      super(*str)
    end
    def print(*str)
      str = str.flatten
      str[0] = "#{version})) \#{str[0]}"
      super(*str)
    end
  EOT
  
  pids << fork do
    ENV["AP_VERSION"] = version
    files.each {|file| require file }
  end
end
pids.each {|pid| Process.wait(pid) }