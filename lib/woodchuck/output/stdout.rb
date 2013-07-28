require 'woodchuck/output'

module Woodchuck::Output
  class Stdout < Woodchuck::Output::Base
    def initialize(settings)
      super(settings)
      @type = :stdout
    end
  
    def handle(event)
      puts event.to_hash
      #@logger.info "Logging event to STDOUT", event.to_hash
    end
  end
  
  # register myself
  @@output_types[:stdout] = :Stdout
  
end
