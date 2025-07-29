require "unicorn"
require "unicorn/launcher"

module UnicornRails
  require "unicorn_rails/version"
end

# Load rackup in case we’re on Rack 3+
begin
  require "rackup"
rescue LoadError
  # rackup not available, assume Rack < 3
end

# Define our handler class exactly as before
module Rack
  module Handler
    class Unicorn
      class << self
        def run(app, options = {})
          unicorn_options = {
            listeners: ["#{options[:Host]}:#{options[:Port]}"]
          }

          env = environment
          cfg = if ::File.exist?("config/unicorn/#{env}.rb")
                  "config/unicorn/#{env}.rb"
                elsif ::File.exist?("config/unicorn.rb")
                  "config/unicorn.rb"
                end

          if cfg
            unicorn_options[:config_file] = cfg
            # if that config already sets `listen`, don’t pass our default listeners
            unicorn_options.delete(:listeners) if ::File.read(cfg) =~ /^\s*listen\s/
          else
            unicorn_options[:timeout]          = 31 * 24 * 60 * 60
            unicorn_options[:worker_processes] = (ENV["UNICORN_WORKERS"] || "1").to_i
          end

          ::Unicorn::Launcher.daemonize!(unicorn_options) if options[:daemonize]
          ::Unicorn::HttpServer.new(app, unicorn_options).start.join
        end

        def environment
          ENV["RACK_ENV"] || ENV["RAILS_ENV"]
        end
      end
    end
  end
end

# Register under whichever handler module is available
handler_mod =
  if defined?(Rack::Handler) && Rack::Handler.respond_to?(:register)
    Rack::Handler
  elsif defined?(Rackup::Handler) && Rackup::Handler.respond_to?(:register)
    Rackup::Handler
  end

if handler_mod
  target = handler_mod == Rack::Handler ? "Rack::Handler::Unicorn" : "Rackup::Handler::Unicorn"
  handler_mod.register "unicorn", target
end

# Provide a default hook for both Rack and rackup
def self.default(options = {})
  if defined?(Rackup::Handler) && Rackup::Handler.respond_to?(:get)
    Rackup::Handler.get('unicorn')
  else
    Rack::Handler::Unicorn
  end
end
