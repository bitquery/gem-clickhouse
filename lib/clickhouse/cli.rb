require "thor"
require "launchy"
require "clickhouse"

module Clickhouse
  class CLI < Thor

    DEFAULT_URLS = "http://localhost:8123"

    desc "server [HOSTS]", "Start a Sinatra server as ClickHouse client (HOSTS should be comma separated URIs)"
    method_options [:port, "-p"] => 1982, [:username, "-u"] => :string, [:password, "-P"] => :string
    def server(urls = DEFAULT_URLS)
      run! :server, urls, options do
        Launchy.open "http://localhost:#{options[:port]}"
      end
    end

    desc "console [HOSTS]", "Start a Pry console as ClickHouse client (HOSTS should be comma separated URIs)"
    method_options [:username, "-u"] => :string, [:password, "-P"] => :string
    def console(urls = DEFAULT_URLS)
      run! :console, urls, options
    end

    map "s" => :server
    map "c" => :console

  private

    def run!(const, urls, options, &block)
      require_relative "cli/client"
      require_relative "cli/#{const}"
      connect! urls, options
      self.class.const_get(const.to_s.capitalize).run!(:port => options["port"], &block)
    end

    def connect!(urls, options)
      config = options.merge(:urls => urls.split(",")).inject({}){|h, (k, v)| h[k.to_sym] = v; h}
      Clickhouse.establish_connection config
    end

    def method_missing(method, *_args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `clickhouse help`."
    end

  end
end
