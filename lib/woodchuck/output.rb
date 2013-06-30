require 'socket'

module Woodchuck::Output
  class Base
    
    def initialize(settings)
      @settings = settings
    end
    
    def handle(event)
      true
    end
  end
  
  ## 
	# Much like how @@input_types works, the @@output_types class variable
	# dynamically maps output destinations to plugins loaded. Each plugin 
	# will register itself in the @@output_types class variable so that 
	# the appropiate plugin can be initialized when a configuration file 
	# is read.
  @@output_types = {}

end

# Dynamically load any format plugins
$LOAD_PATH.each do |dir|
  if File.directory? "#{dir}/woodchuck/output"
    Dir.foreach("#{dir}/woodchuck/output") do |file|
      if file.end_with? '.rb'
        require "woodchuck/output/#{File.basename(file, '.rb')}"
      end
    end
  end
end