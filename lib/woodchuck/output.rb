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