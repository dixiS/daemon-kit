# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{File.expand_path(File.dirname(__FILE__))}/.." unless defined?( DAEMON_ROOT )

require "rubygems"
require "bundler/setup"

module DaemonKit
  class << self
    def boot!
      unless booted?
        pick_boot.run
      end
    end

    def booted?
      defined? DaemonKit::Initializer
    end

    def pick_boot
      (vendor_kit? ? VendorBoot : GemBoot).new
    end

    def vendor_kit?
      File.exist?( "#{DAEMON_ROOT}/vendor/daemon-kit" )
    end
  end

  class Boot
    def run
      load_initializer
      DaemonKit::Initializer.run
    end
  end

  class VendorBoot < Boot
    def load_initializer
      require "#{DAEMON_ROOT}/vendor/daemon-kit/lib/daemon_kit/initializer"
    end
  end

  class GemBoot < Boot
    def load_initializer
      begin
        require 'rubygems' unless defined?( ::Gem )
        gem 'daemon-kit'
        require 'daemon_kit/initializer'
      rescue ::Gem::LoadError => e
        msg = <<EOF

You are missing the daemon-kit gem. Please install the following gem:

sudo gem install daemon-kit

EOF
        $stderr.puts msg
        exit 1
      end
    end
  end
end

DaemonKit.boot!
