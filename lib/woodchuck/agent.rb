#require 'yajl'
#require 'socket'
require 'thread'

require 'woodchuck/config'
require 'woodchuck/output'
require 'woodchuck/input'
require 'woodchuck/format'

module Woodchuck
  class Agent
  
    attr_accessor :inputs, :filters, :outputs
    
    def initialize(config_obj=nil)
      @config = config_obj
    end
    
    
    def configure(config_obj=nil)
      if @config.nil? and config_obj.nil?
        raise StandardError, "Need to supply Woodchuck::Config object"
      elsif @config.nil?
        @config = config_obj 
      end
      
      # Set up all the log sources
      @inputs = []
      input_types = Woodchuck::Input.class_variable_get(:@@input_types)
      @config.inputs.each do |type,sources|
        klass = input_types[type]
        sources.each do |settings|
          @inputs << Woodchuck::Input::const_get(klass).new(settings)
        end
      end
      
      # Setup all the filters  
      @filters = []
      
      # Setup all the output locations
      @outputs = []
      output_types = Woodchuck::Output.class_variable_get(:@@output_types)
      @config.outputs.each do |type,destinations|
        klass = output_types[type]
        destinations.each do |settings|
          @outputs << Woodchuck::Output::const_get(klass).new(settings)
        end
      end
      
  		#options[:log_level] ||= :info
      #@logger = Woodchuck::Logger.new(::STDOUT)
  		#@logger.level = options[:log_level]
  		
      @mutex = Mutex.new
  
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