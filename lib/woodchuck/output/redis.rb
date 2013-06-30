require 'redis'
require 'redis/namespace'

module Woodchuck::Output
  class Redis < Woodchuck::Output::Base
    attr_accessor :url, :host, :port, :db, :namespace
  
    def initialize(log_level)
      super(log_level)
      @type = :redis
      @url = Addressable::URI.parse(ENV['REDIS_URL'] || 'redis://localhost:6379/9')
      @namespace = ENV['REDIS_NAMESPACE'] || 'logstash:woodchuck'
    end
  
    def redis
      client = ::Redis.new(:url => url)
      ::Redis::Namespace.new(namespace, :redis => client)
    end
  
    def handle(event)
      redis.lpush("events", event.to_json)
      @logger.info "Logging event to Redis", event.to_hash
    end
  end
  
  # register myself
  @@output_types[:redis] = :Redis
  
end
