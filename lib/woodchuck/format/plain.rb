

module Woodchuck
  module Format
    class Plain < Woodchuck::Format
      protected
    
      ## 
      # construct_hash() for plain text formats. This input format does not 
      # attempt to decode the input in any specific format and just treats
      # the log entry as raw text. 
      # 
      # @param [String] path specification to the source of the log entry
      # @param [String] line log entry data
      # @return [Hash] initial values for Woodchuck::Event
      # 
      def construct_hash(path, line)
        super(path, line).merge(
          {
            :message => line.strip
          }
        )
      end
    end
  end
end
