#require 'yajl'
#require 'socket'
require 'thread'

require 'woodchuck/config'
require 'woodchuck/output'
require 'woodchuck/input'
require 'woodchuck/format'

module Woodchuck
  class Agent
  
    attr_accessor :logger
    
    def initialize(config)
      
      # Set up all the log sources
      @inputs = []
      input_types = Woodchuck::Input.class_variable_get(:@@input_types)
      config.inputs.each do |type,sources|
        klass = input_types[type]
        sources.each do |settings|
          @inputs << Woodchuck::Input::const_get(klass).new(settings)
        end
      end
      
      # Setup all the filters  
      @filters = []
      
      # Setup all the output locations
      #@outputs = []
      #config.outputs.each {|type,settings|
      #  @outputs << Woodchuck::Output::type_map[type].new settings
      #}
      
  		#options[:log_level] ||= :info
      #@logger = Woodchuck::Logger.new(::STDOUT)
  		#@logger.level = options[:log_level]
  		
      @mutex = Mutex.new
      
  		#@input_format = case options[:input_format]
  		#	when :json_event
  		#		Woodchuck::Input::JsonEvent.new
  		#	else
  		#		Woodchuck::Input::Plain.new
  		#	end
  
      #@watcher = Woodchuck::Watcher.new(self, options[:log_level], @input_format, @paths)
    end
  
    def start(blocking=false)
      @mutex.synchronize do
        return if @stop == false
        @stop = false
      end
      @watcher_thread = Thread.new { @watcher.start }
      @watcher_thread.join if blocking
    end
    
    def stop
      @mutex.synchronize do
        return if @stop == true
        @stop = true
      end
      Thread.kill(@watcher_thread) if @watcher_thread
    end
    
  end
end