require 'woodchuck/logger'
require 'socket'

##
# Info concerning logstash event fields (#logstash on 11-Jun-2014)
#
#11:05 [wt0f] Question for those that have been using logstash for some time. I am using a modified version of woodchuck to ship logs to logstash and it creates fields like @message, @source, @tags, etc. Are the @ forms standard?
#11:05 [whack] there's no @message @source or @tags anymore
#11:06 [whack] @tags is now just the tags field
#11:06 [whack] @message is just message
#11:06 [whack] @source is gone
#11:06 [wt0f] Ok, so I should go rewrite woodchuck to not produce any field staring with @.
#11:06 [whack] just @timestamp and @version
#11:06 [whack] @timestamp is iso8601 string w/ millisecond precision in UTC time
#11:06 [whack] @version is a string "1"
#11:07 [wt0f] Is there any docs out there that define the "standard" fields?
#11:07 [whack] not at this time, but what I said above is basically it
#11:07 [wt0f] OK.
#11:08 [wt0f] How about source_path and source_host? Standard or woodchuck specific?
#11:08 [avleen] "path" and "host are pretty common too
#11:09 [whack] wt0f: @source_path and @source_host are gone, often just 'path' or 'host' in events
#11:10 [wt0f] Woodchuck also produces @fields and @type. Not sure what @fields would contain if it is used any more. I assume @type is really just type now.
#11:12 [whack] @type is just type
#11:12 [whack] @fields is gone
#11:16 [wt0f] OK. Thanks. Two final questions. Are there any other fields that should be implemented not discussed above? And I am also seeing a _type in the dashboard. Is this internal to logstash?
#11:17 [whack] _type is an elasticsearch thing
#11:17 [whack] @timestamp and @version are the only required fields.
#11:17 [whack] everything else is up to you or your app
#11:18 [wt0f] OK. Very good. Thank you whack for clearing up the confusion!

class Woodchuck::Event
  
  attr_accessor :timestamp, :message, :tags, :type, :path, :host
  
  def initialize(init_hsh)
    @timestamp = init_hsh["@timestamp"] || init_hsh[:timestamp]
    @message = init_hsh["message"] || init_hsh[:message]
    @tags = init_hsh["tags"] || init_hsh[:tags] || []
    @type = init_hsh["type"] || init_hsh[:type]
    @path = init_hsh["path"] || init_hsh[:path]
    @host = init_hsh["host"] || init_hsh[:host] || Socket.gethostname
  end
  
  def method_missing(symbol, *args, &block)
    if to_hash.has_key?(symbol)
      to_hash
    else
      super(symbol, *args, &block)
    end
  end
  
  def to_hash
    {
      'message' => message,
      'type' => type,
      'tags' => tags,
      'path' => path,
      'host' => host,
      '@timestamp' => timestamp,
      '@version' => 1,
    }
  end
  
  def to_json(*args)
    to_hash.to_json(*args)
  end
  
  def to_s
    to_json
  end
end
