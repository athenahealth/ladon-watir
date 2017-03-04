require 'watir'

module Ladon
  module Watir
    # Represents a Watir WebDriver-based browser, with a few useful extensions.
    #
    # This is a good place to encapsulate things like script execution.
    class Browser < ::Watir::Browser
      # Constructs a browser to be driven locally.
      #
      # @return [Ladon::Watir::Browser] The new browser object.
      def self.new_local(type:)
        return self.new(type)
      end

      # Constructs a browser to be driven remotely on a grid.
      #
      # @return [Ladon::Watir::Browser] The new browser object.
      def self.new_remote(url:, type:, platform:)
        capabilities = Selenium::WebDriver::Remote::Capabilities
                       .send(type, platform: platform)

        @client = Selenium::WebDriver::Remote::Http::Default.new

        # Increase timeout to 20 minutes to allow queued tests to process when
        # grid resources free up.
        @client.open_timeout = 60 * 20 # seconds.
        @client.read_timeout = 60 * 20 # seconds.

        return self.new(:remote,
                        url: url.to_s,
                        desired_capabilities: capabilities,
                        http_client: @client)
      end

      # Get the height of the screen.
      #
      # @return [Integer] Height of the screen in pixels.
      def screen_height
        return execute_script('return screen.height;')
      end

      # Get the width of the screen.
      #
      # @return [Integer] Width of the screen in pixels.
      def screen_width
        return execute_script('return screen.width;')
      end
    end
  end
end
