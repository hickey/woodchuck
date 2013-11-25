require 'thread'

require 'woodchuck/config'
require 'woodchuck/output'
require 'woodchuck/input'
require 'woodchuck/format'

module Woodchuck
  
  ##
  # Woodchuck::Agent uses EventMachine to automate the collection of log
  # messages and high performance. Woodchuck::Agent manages the creation 
  # of the individual plugins for each data source.
  # 
  # When a data source receives some amount of log messages, the blob of
  # log messages is handed off to the responsible plugin for seperation 
  # and creation of the Woodchuck::Event object to represent the log 
  # information. The plugin then returns the Woodchuck::Event object to
  # the agent for processing by the filter plugins and then finally by 
  # the output plugins.  
  class Agent
  
    attr_accessor :inputs, :filters, :outputs
    
    ##
    # Create the Woodchuck agent entity and initialize internal structure
    # 
    # @param [Woodchuck::Config] config_obj optional parameter to send a configuration to the agent instance
    def initialize(config_obj=nil)
      @config = config_obj
      @inputs = []
      @filters = []
      @outputs = []
      @output_queue = SizedQueue.new(20)
      @mutex = Mutex.new
    end
    
    ##
    # Finalize configuration and instantiate all the plugins that will be needed. 
    # 
    # @param [Woodchuck::Config] config_obj configuration object if not specified in constructor
    def configure(config_obj=nil)
      if @config.nil? and config_obj.nil?
        raise StandardError, "Need to supply Woodchuck::Config object"
      elsif @config.nil?
        @config = config_obj 
      end
      
      # Set up all the log sources
      input_types = Woodchuck::Input.class_variable_get(:@@input_types)
      @config.inputs.each do |type,sources|
        klass = input_types[type]
        if klass.nil?
          raise StandardError, "Unknown input type of #{type}"
        end
        sources.each do |settings|
          settings[:queue] = @output_queue.clone
          @inputs << Woodchuck::Input::const_get(klass).new(settings)
        end
      end
      
      # Setup all the filters  

      
      # Setup all the output locations
      output_types = Woodchuck::Output.class_variable_get(:@@output_types)
      @config.outputs.each do |type,destinations|
        klass = output_types[type]
        if klass.nil?
          raise StandardError, "Unknown output type of #{type}"
        end
        destinations.each do |settings|
          @outputs << Woodchuck::Output::const_get(klass).new(settings)
        end
      end
      
      #options[:log_level] ||= :info
      #@logger = Woodchuck::Logger.new(::STDOUT)
      #@logger.level = options[:log_level]
      
      self
    end
  
    ##
    # Start the agent running and gathering input from its sources
    # 
    # @param [Boolean] blocking cause the agent to wait for watcher thread to exit
    def start(blocking=false)
      @mutex.synchronize do
        return if @stop == false
        @stop = false
      end
      @inputs_thread = Thread.new { inputs_thread_start }
      @outputs_thread = Thread.new { outputs_thread_start }
      #begin
      #  @inputs_thread.join if blocking
      #rescue Exception => e
      #  puts "Exception: #{e}"
      #end
      while true
        sleep 5
      end
    end
    
    ##
    # Stop the watcher thread if it is running
    def stop
      @mutex.synchronize do
        return if @stop == true
        @stop = true
      end
      Thread.kill(@inputs_thread) if @inputs_thread
    end
    
    ##
    # Core and magic of the agent. We use EventMachine to handle watching
    # each of the inputs for log entries in an event driven method. 
    #
    # This starts the ball rolling by receiving a log entry from EventMachine.
    # Since the plugin is tied to the path where the entry was received from,
    # we send the entry to that plugin for processing. The plugin has the
    # responsibility to prepare the entry and then load it into a 
    # Woodchuck::Event instance then push the event to the output code
    # to be routed to individual locations.
    # 
    # The result being much more efficent but at the cost of making all 
    # the plugins implement a receive_data method to handle incoming data.
    def inputs_thread_start
      EventMachine.run do
        @inputs.each do |plugin|
          # Tell EventMachine to watch the plugin source
          EventMachine::FileGlobWatchTail.new(plugin.source) do |emtail, entry| 
            begin
              plugin.receive_data(entry) 
            rescue Exception => e
              puts "Exception: #{e}"
            end
          end
        end
      end
      puts "EventMachine exiting"
    end
    
    
    ##
    
    def outputs_thread_start
      EventMachine.run do
        queue = @output_queue.clone
        while true
          event = queue.deq
          @outputs.each do |plugin|
            plugin.handle event
          end
        end
      end
    end
  end
end