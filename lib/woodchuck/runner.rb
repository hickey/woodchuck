require 'fallen'

module Woodchuck::Runner
  extend Fallen
  
  ##
  # Woodchuck::Runner is a helper module that does most of the work to 
  # bridge between the woodchuck wrapper script and a fully running
  # implementation of the Woodchuck::Agent. It is responsible for gathering
  # all the necessary information from the environment and command line, 
  # then setup and transfer control over to the Woodchuck::Agent 
  # instance. When the agent instance returns, the process will exit
  # and return control to the controlling terminal. 
  
  def logger
    @logger ||=  Woodchuck::Logger.new(STDOUT)
  end
  
  def logger=(log)
    @logger = log
  end
  
  
  module_function
  
  ##
  # Read and process the command line arguments. Command line arguments simply
  # set the appropriate data structures in a Woodchuck::Config instance. In
  # most cases a config file should be specified and all the settings should
  # be set there. 
  # 
  # @param [Array] args array of command line arguments
  # @returns [Woodchuck::Config] configuration object
  #
  def read(args=ARGV)
    config = Woodchuck::Config.new
    
    optparse = OptionParser.new do |opts|
      opts.banner = 'Woodchuck provide a light weight log shipper for logstash.'
      opts.separator  ''
      opts.separator  "Usage: #{File.basename $0} OPTIONS"
      opts.separator  ''
      opts.separator  "    Options: "
      opts.separator  ''

      opts.on('-c', '--config FILE', 'read configuration from file') do |file|
        config.read file
      end
      #opts.on('-l', '--log-level LEVEL', [:debug, :warn, :info, :error, :fatal], 'set the log level') do |level|
      #  options[:log_level] = level.to_sym
      #end
      opts.on('-o', '--output URL', 'set the output') do |output|
        config.add_output output
      end
      opts.on('-i', '--input PATH[:FORMAT]', Array, 'A list of file paths to watch') do |paths|
        config.add_input paths
      end
      
      opts.separator ''
      opts.separator "Input formats can be specified as json or plain. Plain is default."
      opts.separator ''
    end
    optparse.parse!(args)
    config
  end
  
  
  ##
  # Really just a helper routine that kicks everything off. It is the glue
  # between the woodchuck wrapper script and the Woodchuck::Agent object 
  # that does all the work. 
  # 
  # @param [Woodchuck::Config] config Configuration object holding settings for the agent
  # 
  def run(config)
    agent = Woodchuck::Agent.new(config).configure
    agent.start(true)
    Signal.trap('INT') do
      @logger.warn :signal => signal
      agent.stop
      exit 0
    end    
  end
end
