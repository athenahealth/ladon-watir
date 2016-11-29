require 'watir'
require 'ladon'
require 'ladon/watir/web_app_finite_state_machine'

module Ladon
  module Watir
    # Base class for all Watir WebDriver-based browser automation.
    #
    # @abstract
    #
    # @attr_reader [Watir::Browser] browser The Watir WebDriver browser object.
    class BrowserAutomation < Ladon::Automator::ModelAutomation
      attr_reader :browser

      NO_GRID_DEFAULT = :NONE
      FULL_SCREEN_SIZE = :FULL

      OS_FLAG = :os
      BROWSER_FLAG = :browser
      GRID_FLAG = :grid_url

      BROWSER_SETUP_FLAGS = {
        width: { default: FULL_SCREEN_SIZE,
                 handler: lambda do |automation, flag_value|
                   automation.browser_width = flag_value
                 end },

        height: { default: FULL_SCREEN_SIZE,
                  handler: lambda do |automation, flag_value|
                    automation.browser_height = flag_value
                  end },

        ui_url: { default: ->(automation) { automation.class.default_url },
                  handler: lambda do |automation, flag_value|
                    automation.browser.goto(flag_value)
                  end }
      }.freeze

      # Mapping of supported browser configuration flag names to a hash of
      # metadata about those flags.
      #
      # The +setup+ method processes these flags in the order they appear
      # (Ruby 1.9+), defaulting to the metadata's +:default+ value. The :default
      # may optionally be specified as a proc taking the current +automation+
      # instance. This proc should return the desired default value.
      #
      # @return [Hash] Map of flag names to hash of metadata (default value,
      #   flag handler.)
      def self.browser_setup_flags
        BROWSER_SETUP_FLAGS
      end

      # Defining the URL to which the browser should be pointed.
      # Subclasses can override this to customize their defaults.
      #
      # @return [String] *MUST* return a String (which should be a URL.)
      def self.default_url
        'about:blank'
      end

      # Builds the +Ladon::Watir::WebAppFiniteStateMachine+ that will represent
      # the web application, with states as page objects and transitions driven
      # by browser navigation.
      #
      # @return [Ladon::Watir::WebAppFiniteStateMachine] The finite state
      #   machine that will power the automation.
      def build_model
        @browser = self.build_browser
        self.model = Ladon::Watir::WebAppFiniteStateMachine.new(@browser)
      end

      # Create an instance of the Watir::Browser. Depending on the flags given
      # to this automation, supports spawning the browser either locally or via
      # any standard Selenium Grid instance.
      def build_browser
        browser_type = flags.get(BROWSER_FLAG, default_to: default_browser)
                            .to_sym
        grid_url = flags.get(GRID_FLAG, default_to: NO_GRID_DEFAULT)

        return local_browser(type: browser_type) if grid_url == NO_GRID_DEFAULT

        return remote_browser(url: grid_url, type: browser_type)
      end

      # The first phase of the automation.
      # Processes the class' defined browser setup flags, configuring the
      # browser appropriately.
      def setup
        self.class.browser_setup_flags.each do |flag, metadata|
          default_val = metadata[:default]

          # "default" can be a proc consuming this automation instance,
          # returning the default value
          default_val = default_val.call(self) if default_val.is_a?(Proc)

          # get the flag and fire the callback
          flag_val = flags.get(flag, default_to: default_val)
          metadata[:handler].call(self, flag_val)
        end
      end

      # The last phase of the automation. Quits the browser.
      def teardown
        @browser.quit
      end

      # Resize the browser's width to the given value.
      #
      # @param [Integer] width Should be the desired width of the browser, in
      # number of pixels.
      #   May be the constant value +FULL_SCREEN_SIZE+ to indicate to maximize
      #   available width.
      def browser_width=(width)
        if width == FULL_SCREEN_SIZE
          width = browser.execute_script('return screen.width;')
        end

        browser.window.resize_to(width.to_i, browser.window.size.height)
      end

      # Resize the browser's height to the given value.
      #
      # @param [Integer] height Should be the desired height of the browser, in
      #   number of pixels.
      #   May be the constant value +FULL_SCREEN_SIZE+ to indicate to maximize
      #   available height.
      def browser_height=(height)
        if height == FULL_SCREEN_SIZE
          height = browser.execute_script('return screen.height;')
        end

        browser.window.resize_to(browser.window.size.width, height.to_i)
      end

      private

      # Constructs a browser to be driven locally.
      #
      # @private
      # @return [Watir::Browser] The new browser object.
      def local_browser(type:)
        return ::Watir::Browser.new(type)
      end

      # Constructs a browser to be driven remotely on a grid.
      #
      # @private
      # @return [Watir::Browser] The new browser object.
      def remote_browser(url:, type:)
        platform = flags.get(OS_FLAG, default_to: default_platform).to_sym
        capabilities = Selenium::WebDriver::Remote::Capabilities
                       .send(type, platform: platform)

        @client = Selenium::WebDriver::Remote::Http::Default.new

        # Increase timeout to 20 minutes to allow queued tests to process when
        # grid resources free up.
        @client.timeout = 60 * 20 # seconds.

        return ::Watir::Browser.new(:remote,
                                    url: url.to_s,
                                    desired_capabilities: capabilities,
                                    http_client: @client)
      end
    end
  end
end
