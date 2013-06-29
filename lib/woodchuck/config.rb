module Woodchuck
  
  class Config
    
    attr_reader :options
    
    
    def initialize(filename)
      @options = {}
      read(filename)
    end
    
    
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
      re_item = Regexp.new %r{(\w+)\s*=\s*([^=]+)\s*\n}
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
            puts "Houston we have a problem with the config"
            exit 2
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
            puts "Trying to close config too many times"
            exit 2
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
    
  end
  
  DEFAULT_OUTPUT = :stdout
end