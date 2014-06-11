# Woodchuck

A lightweight log shipper for logstash written in Ruby.

Inspired by [beaver](https://github.com/josegonzalez/beaver) and [logstash](https://github.com/logstash/logstash) itself. Fair warning, it's a work in progress ;)

## Installation

Install as a gem:

    $ gem install woodchuck

And then execute:

    $ woodchuck

## Usage
```bash
woodchuck --files /var/log/syslog,/var/log/apache/**/*,/var/log/nginx/*.log --output redis
```

### Options
```
* -c, --config FILE   - Read configuration from file
* -h, --help          - Help!
* -o, --output        - The output to send to [ stdout, redis ]
* -d, --debug         - Turn on debug logging
```
## Coming soon

* regular expressions (why not!)
* ZeroMQ and TCP output support
* Performance enhancements

## Configuration File
The configuration file format is very much like the standard logstash file format. At the moment only the 'inputs' and 'outputs' sections are active. 

### Inputs
Currently only the file input is implemented which supports a path and type settings. For example: 
```
inputs {
  file {
    path = "/var/log/messages"
    type = "syslog"
  }
}
```
Events are generated with the following attributes:

* message
* type
* tags
* path
* host
* @timestamp (UTC in ISO8601 format)
* @version

### Outputs
The supported outputs at this time are redis, stdout and zeromq. In the future tcp, udp and unix outputs will be implemented.

#### Redis
Redis is the principle mechanism for shipping logs to logstash. The redis output definition will accept host, port, and namespace settings. In addition the REDIS_URL and REDIS_NAMESPACE environmental variables will override settings in the definition. REDIS_URL should be specified as 'redis://<HOSTNAME>:<PORT>/'. 

The namespace defaults to 'logstash' if not specified. Log events are created with the 'events' key. As a result, logstash needs to be configured to read the list with the key 'logstash:events' from redis. 
```
outputs {
  redis {
    host = 10.1.40.47
  }
}
```

#### Stdout
Stdout is really only useful for debugging or shipping logs into another log processing engine. Log entries will be written by dumping the Woodchuck::Event out as a Ruby hash. See the Inputs section for the structure of the Woodchuck::Event. 

#### Zeromq
Zeromq is not functional at this time.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
