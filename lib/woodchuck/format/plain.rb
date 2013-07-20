#require 'woodchuck/input'

module Woodchuck
  module Format
    class Plain < Woodchuck::Format
    	protected
    
    	def prepare_hash(path, line)
    		super(path, line).merge(
    			{
    				:message => line.strip
    			}
    		)
    	end
    end
  end
end
