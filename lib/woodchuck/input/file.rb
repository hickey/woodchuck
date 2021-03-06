require "eventmachine-tail"
require "woodchuck/event"
require "time"
require "socket"


module Woodchuck::Input
  class File < EventMachine::FileTail

    def initialize(settings)
      unless settings.member? :path
        raise StandardError, "path is a required entry for file types"
      end
      @config = settings
      
      # silently squelch any log files that can not be opened
      begin
        super(settings[:path], 0)
        @buffer = BufferedTokenizer.new
      rescue Errno::ENOENT; end
    end
    
    ##
    # Return a reference to what is being watched
    #
    # @return [String] Path to file being watched
    def source 
      @config[:path]
    end
    
    
    ##
    # Return a reference to what "type" is generated from the source
    #
    # @return [String] type
    def type 
      @config[:type]
    end
    
    
    ##
    # Handle new data received from the source. This is called from 
    # EventMachine when new data is written to the source. It comes
    # in as a blob and may contain several text entries. 
    # 
    # @param data data received from the source
    def receive_data(data)
      @buffer.extract(data).each do |line|
        event = Woodchuck::Event.new ({ :path => source,
                                       :host => Socket.gethostname,
                                       :message     => line,
                                       :type        => type,
                                       :timestamp   => Time.now.utc.iso8601(6) })
        @config[:queue].push event
      end
    end
  end


  # register myself
  @@input_types[:file] = :File
  
end
