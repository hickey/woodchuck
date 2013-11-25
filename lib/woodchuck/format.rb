require 'socket'
require 'addressable/uri'

module Woodchuck
  class Format

    protected
  
    ##
    # construct_hash() will accept the log entry in which ever format that 
    # has been specified by the input definition and build a hash that is
    # used to seed the Woodchuck::Event object. The construct_hash() method
    # should be overwritten by each individual input format class. 
    # 
    # @param [String] path specification to the source of the log entry
    # @param [String] line log entry data
    # @return [Hash] initial values for Woodchuck::Event
    # 
    def construct_hash(path, line)
      host = Socket.gethostname
  
      {
        :source_path => path,
        :line => line,
        :source_host => host,
        :timestamp => Time.now.utc.iso8601(6),
        :source => Addressable::URI.new(:scheme => 'file', :host => host, :path => path),
        :type => '',
        :fields => {},
        :tags => []
      }
    end
  end
end

# Dynamically load any format plugins
$LOAD_PATH.each do |dir|
  if File.directory? "#{dir}/woodchuck/format"
    Dir.foreach("#{dir}/woodchuck/format") do |file|
      if file.end_with? '.rb'
        require "woodchuck/format/#{File.basename(file, '.rb')}"
      end
    end
  end
end