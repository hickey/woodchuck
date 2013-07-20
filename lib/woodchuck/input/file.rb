require "eventmachine-tail"

module Woodchuck::Input
  class File < EventMachine::FileTail

	  def initialize(settings)
	    unless settings.member? :path
	      raise StandardError, "path is a required entry for file types"
      end
      @config = settings
      
	    super(settings[:path], 0)
	    #@input_format = @@input_format
	    #@output = @@output

	    @buffer = BufferedTokenizer.new
    end
    
    ##
    # Return a reference to what is being watched
    #
    # @return [String] Path to file being watched
    def source 
      @config[:path]
    end
    
    ##
    # Handle new data received from the source. This is called from 
    # EventMachine when new data is written to the source. It comes
    # in as a blob and may contain several text entries. 
    # 
    # @param data data received from the source
    def receive_data(data)
	    @buffer.extract(data).each do |line|
		    @output.handle(@input_format.create(path, line))
	    end
    end
  end


  # register myself
  @@input_types[:file] = :File
  
end
