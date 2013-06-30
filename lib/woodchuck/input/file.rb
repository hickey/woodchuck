require "eventmachine-tail"

module Woodchuck::Input
  class File < EventMachine::FileTail

	  def initialize(settings)
	    unless settings.member? :path
	      raise StandardError, "path is a required entry for file types"
      end
        
	    super(settings[:path], 0)
	    #@input_format = @@input_format
	    #@output = @@output

	    @buffer = BufferedTokenizer.new
    end

    def receive_data(data)
	    @buffer.extract(data).each do |line|
		    @output.handle(@input_format.create(path, line))
	    end
    end
  end


  # register myself
  @@input_types[:file] = :File
  
end
