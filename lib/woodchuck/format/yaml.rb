require 'yaml'

module Woodchuck
  module Format
    class Yaml < Woodchuck::Format
    	protected
    
      ## 
      # construct_hash() for YAML formats. This input format will send 
      # any input received through the YAML parser.
      # 
      # @param [String] path specification to the source of the log entry
      # @param [String] line JSON data
      # @return [Hash] initial values for Woodchuck::Event
      #
    	def construct_hash(path, line)
    		super(path, line).merge(
    			parse_yaml(line)
    		)
    	end
    
    	def parse_yaml(line)
    		begin
    			YAML.parse(line)
    		rescue
    			{}
    		end
    	end
    end
  end
end
