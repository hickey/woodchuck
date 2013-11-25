require 'json'

module Woodchuck
  module Format
    class Json < Woodchuck::Format
      protected
    
      ## 
      # construct_hash() for JSON formats. This input format will send 
      # any input received through the JSON parser.
      # 
      # @param [String] path specification to the source of the log entry
      # @param [String] line JSON data
      # @return [Hash] initial values for Woodchuck::Event
      #
      def construct_hash(path, line)
        super(path, line).merge(
          parse_json(line)
        )
      end
    
      def parse_json(line)
        begin
          JSON.parse(line)
        rescue
          {}
        end
      end
    end
  end
end
