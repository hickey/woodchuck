require 'redis'
require 'redis/namespace'

module Woodchuck::Output
  class Redis < Woodchuck::Output::Base
    attr_accessor :url, :host, :port, :db, :namespace
  
    def initialize(settings)
      super(settings)
      @type = :redis
      @url = Addressable::URI.parse(ENV['REDIS_URL'] || "redis://#{@settings[:host]}:#{@settings[:port] || 6379}/")
      @namespace = ENV['REDIS_NAMESPACE'] || @settings[:namespace] || 'logstash'
      
      client = ::Redis.new(:url => @url)
      @conn = ::Redis::Namespace.new(@namespace, :redis => client)
    end
  
  
    def handle(event)
      @conn.lpush("events", event.to_json)
      #@logger.info "Logging event to Redis", event.to_hash
    end
  end
  
  # register myself
  @@output_types[:redis] = :Redis
  
end
