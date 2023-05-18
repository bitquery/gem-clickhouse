require "uri"
require "forwardable"
require "csv"
require "json"
require "time"

require "faraday"
require "pond"
require "active_support/dependencies/autoload"
require "active_support/number_helper"
require "active_support/core_ext/string/inflections"

require "clickhouse/cluster"
require "clickhouse/connection"
require "clickhouse/utils"
require "clickhouse/error"
require "clickhouse/version"

module Clickhouse

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger if instance_variables.include?(:@logger)
  end

  def self.configurations=(configurations)
    @configurations = configurations.inject({}){|h, (k, v)| h[k.to_s] = v; h}
  end

  def self.configurations
    @configurations if instance_variables.include?(:@configurations)
  end

  def self.establish_connection(arg = {})
    config = arg.is_a?(Hash) ? arg : (configurations || {})[arg.to_s]
    if config
      connect!(config)
    else
      raise InvalidConnectionError, "Invalid connection specified: #{arg.inspect}"
    end
  end

  def self.connect!(config = {})
    @connection = connect(config)
    @connection.connect!
  end

  def self.connect(config = {})
    klass = (config[:urls] || config["urls"]) ? Cluster : Connection
    klass.new(config)
  end

  def self.connection
    @connection if instance_variables.include?(:@connection)
  end

end
