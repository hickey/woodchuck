module Woodchuck
  
  class ConfigError < StandardError
  end
  
  class Config
    
    attr_reader :options
    
    
    def initialize
      @options = {}
    end
    
    
    ##
    # Read a configuration file and parse it into a hash data structure 
    # for processing and producing objects for processing log files.
    #   
    # The hash has three top level keys (:inputs, :filters and :outputs) 
    # each of which contains an array of entries. Each array entry is a 
    # hash of key-value pairs that represents the configuration entry. 
    # Each key is a Ruby symbol. 
    #   
    # @param [String] filename path to the config file
    #
    def read(filename)
      configlines = []
      File.open(filename, 'r') do |f|
        while line = f.gets
          # remove blank lines and comment lines
          unless line =~ %r{^\s*(#[\s\S]+)?$} 
            configlines << line
          end
        end
      end
      
      re_section = Regexp.new %r{(inputs|filters|outputs)\s*\{}
      re_entry = Regexp.new %r{(\w+)\s*\{}
      re_item = Regexp.new %r{(\w+)\s*=\>?\s*([^=]+)\s*\n}
      section = nil
      entry = nil
      block = {}
      subblock = nil
      configlines.each do |line|
        # test for the beginning of a section
        match = re_section.match line
        unless match.nil?
          section = match[1].to_sym
          next
        end
        
        # look for an entry inside the section
        match = re_entry.match line
        unless match.nil?
          entry = match[1].to_sym
          unless block.member? entry
            block[entry] = []
          end
          subblock = {}
          next
        end
        
        # look for item definitions
        match = re_item.match line
        unless match.nil? 
          if section.nil? or entry.nil?
            raise ConfigError, "Definition without a section or entry"
          end
          key = match[1].to_sym
          val = match[2]
          
          # postprocess the value
          val.gsub! /^[\'\"]?([^\'\"]+)[\'\"]?/, '\1'
          
          subblock[key] = val
          next
        end
        
        # end of sections and entries
        if line.match /\}/
          if not entry.nil?
            block[entry] << subblock
            entry = nil
            next
          elsif not section.nil?
            @options[section] = block
            section = nil
            block = {}
            next
          else
            raise ConfigError "Unbalanced braces"
          end
        end
      end
    end
    
    
    def inputs 
      @options[:inputs]
    end
    
    def filters
      @options[:filters]
    end
    
    def outputs
      @options[:outputs]
    end
    
    
    def add_input(path)
      if path.include? ':'
        path, type = path.split ':'
      else
        type = 'syslog'
      end
      @options[:input] << { :file => { :path => path, :type => type }}
    end
    
    def add_output(url)
      
      @options[:output] << { }
    end
    
    def method_missing(name, *args, &block) 
      if name.end_with? '='
        name = name[0.-2]
        @options[:global][name] = args[0]
      end
      @options[:global][name]
    end
  end
  
  DEFAULT_OUTPUT = :stdout
end