require 'fallen'

module Woodchuck::Runner
  extend Fallen
  # extend Fallen::CLI
  extend self
  
  def logger
    @logger ||=  Woodchuck::Logger.new(STDOUT)
  end
  
  def logger=(log)
    @logger = log
  end
    
  def read(args=ARGV)
    config = Woodchuck::Config.new
    
    optparse = OptionParser.new do |opts|
      opts.on('-c', '--config FILE', 'read configuration from file') do |file|
        config.read file
      end
      opts.on('-l', '--log-level [LOG_LEVEL]', [:debug, :warn, :info, :error, :fatal], 'set the log level') do |level|
        options[:log_level] = level.to_sym
      end
      opts.on('-o', '--output [OUTPUT]', 'set the output') do |output|
        config.add_output output
      end
      opts.on('-p', '--paths [PATHS]', Array, 'A list of file paths to watch') do |paths|
        config.add_input paths
      end
      opts.on('-f', '--format [FORMAT]', [:plain, :json_event], 'Input line format') do |input_format|
        options[:input_format] = input_format
      end
    end
    optparse.parse!(args)
    config
  end
  
  def run(config)
    agent = Woodchuck::Agent.new(config)
    agent.start(true)
    Signal.trap('INT') do
      @logger.warn :signal => signal
      agent.stop
      exit 0
    end    
  end
end
