require 'woodchuck/output'

module Woodchuck::Output
  class Stdout < Woodchuck::Output::Base
    def initialize(log_level)
      super(log_level)
      @type = :stdout
    end
  
    def handle(event)
      @logger.info "Logging event to STDOUT", event.to_hash
    end
  end
  
  # register myself
  @@output_types[:stdout] = :Stdout
  
end
