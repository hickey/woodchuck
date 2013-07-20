require 'socket'
require 'addressable/uri'

module Woodchuck
  class Format

    def create(path, line)
  		Woodchuck::Event.new(prepare_hash(path, line))
  	end
  
  	protected
  
  	def prepare_hash(path, line)
  		host = Socket.gethostname
  
  		{
  			:source_path => path,
  			:line => line,
  			:source_host => host,
  			:timestamp => Time.now.utc.iso8601(6),
  			:source => Addressable::URI.new(:scheme => 'file', :host => host, :path => path),
  			:type => 'file',
  			:fields => {},
  			:tags => []
  		}
  	end
  end
end

## Dynamically load any format plugins
#$LOAD_PATH.each do |dir|
#  if File.directory? "#{dir}/woodchuck/format"
#    Dir.foreach("#{dir}/woodchuck/format") do |file|
#      if file.end_with? '.rb'
#        require "woodchuck/format/#{File.basename(file, '.rb')}"
#      end
#    end
#  end
#end