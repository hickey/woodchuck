require 'socket'

module Woodchuck
  module Input
  #class Input
  #  
  #  def create(path, line)
  #		Woodchuck::Event.new(prepare_hash(path, line))
  #	end
  #
  #	protected
  #
  #	def prepare_hash(path, line)
  #		host = Socket.gethostname
  #
  #		{
  #			:source_path => path,
  #			:line => line,
  #			:source_host => host,
  #			:timestamp => Time.now.utc.iso8601(6),
  #			:source => Addressable::URI.new(:scheme => 'file', :host => host, :path => path),
  #			:type => 'file',
  #			:fields => {},
  #			:tags => []
  #		}
  #	end
	#end
	  
    @@input_types = {}
	  
	
  end
end

# Dynamically load any input plugins
$LOAD_PATH.each do |dir|
  if File.directory? "#{dir}/woodchuck/input"
    Dir.foreach("#{dir}/woodchuck/input") do |file|
      if file.end_with? '.rb'
        require "woodchuck/input/#{File.basename(file, '.rb')}"
      end
    end
  end
end

