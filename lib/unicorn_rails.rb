require "unicorn"
require "unicorn/launcher"
require "rackup"             # bring in Rackup::Handler

module UnicornRails
  require "unicorn_rails/version"
end

# Define the Unicorn handler under Rackup::Handler
module Rackup
  module Handler
    class Unicorn
      class << self
        # Called by rackup when you do `-s unicorn`
        def run(app, options = {})
          unicorn_opts = { listeners: ["#{options[:Host]}:#{options[:Port]}"] }

          env = ENV["RACK_ENV"] || ENV["RAILS_ENV"]
          cfg_path = if File.exist?("config/unicorn/#{env}.rb")
                       "config/unicorn/#{env}.rb"
                     elsif File.exist?("config/unicorn.rb")
                       "config/unicorn.rb"
                     end

          if cfg_path
            unicorn_opts[:config_file] = cfg_path
            # if your config already sets `listen`, drop our default listeners
            unicorn_opts.delete(:listeners) if File.read(cfg_path) =~ /^\s*listen\s/
          else
            unicorn_opts[:timeout]          = 31 * 24 * 60 * 60
            unicorn_opts[:worker_processes] = (ENV["UNICORN_WORKERS"] || "1").to_i
          end

          ::Unicorn::Launcher.daemonize!(unicorn_opts) if options[:daemonize]
          ::Unicorn::HttpServer.new(app, unicorn_opts).start.join
        end
      end
    end

    # Register the handler so `rackup -s unicorn` works
    register "unicorn", Unicorn
  end
end

# Helper so Rails/Rake tasks can still resolve the handler if they call .default
def self.default(options = {})
  Rackup::Handler.get("unicorn")
end
