require 'woodchuck/output'

module Woodchuck::Output
  class ZeroMQ < Woodchuck::Output::Base
    def initialize(log_level)
      super(log_level)
      @type = :zeromq
    end
  
    def handle(event)
      @logger.info event.message, event.to_hash
    end
  end
  
  # register myself
  @@output_types[:zeromq] = :ZeroMQ
  
end
