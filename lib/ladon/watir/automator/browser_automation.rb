require 'ladon'
require 'ladon/watir/browser'
require 'ladon/watir/modeler/web_app_finite_state_machine'
require 'page-object'
require 'watir'

module Ladon
  module Watir
    # Base class for all Watir WebDriver-based browser automation.
    #
    # @abstract
    #
    # @attr_reader [Watir::Browser] browser The Watir WebDriver browser object.
    class BrowserAutomation < Ladon::Automator::ModelAutomation
      abstract

      attr_reader :browser
      attr_reader :screenshots

      BROWSER_TYPES = %i(chrome firefox safari ie).freeze
      PLATFORMS = %i(any windows mac linux).freeze

      # Constant value signifying that browser width or height should be
      # maximized.
      FULL_SCREEN_SIZE = :FULL

      # Flag pertaining to browser width.
      WIDTH_FLAG = make_flag(
        :width,
        description: 'Desired browser width in pixels, or FULL for maximum.',
        default: FULL_SCREEN_SIZE
      ) { |width| self.browser_width = width }

      # Flag pertaining to browser height.
      HEIGHT_FLAG = make_flag(
        :height,
        description: 'Desired browser height in pixels, or FULL for maximum.',
        default: FULL_SCREEN_SIZE
      ) { |height| self.browser_height = height }

      # Flag pertaining to the URL to which the browser should initially
      # navigate.
      UI_URL_FLAG = make_flag(
        :ui_url,
        description: 'URL to which the browser should initially navigate.',
        default: 'about:blank',
        class_override: true
      ) { |url| browser.goto(url.to_s) }

      # Flag identifying the type of browser to use.
      BROWSER_FLAG = make_flag(
        :browser,
        description: %{Desired browser type (#{BROWSER_TYPES.join(', ')}).},
        default: :chrome
      ) do |browser_type|
        @browser_type = browser_type.to_sym
        halting_assert('Browser requested must be valid') do
          BROWSER_TYPES.include?(@browser_type)
        end
      end

      # Flag identifying the desired OS platform for the browser (only
      # applicable when using Selenium Grid).
      PLATFORM_FLAG = make_flag(
        :platform,
        description: %{Desired platform (#{PLATFORMS.join(', ')}).},
        default: :any
      ) do |platform|
        @platform = platform.to_sym
        halting_assert('Browser platform requested must be valid') do
          PLATFORMS.include?(@platform)
        end
      end

      # Flag for specifying a Selenium Grid browser session request URL.
      GRID_URL_FLAG = make_flag(
        :grid_url,
        description: 'Selenium Grid URL, if running remotely.',
        default: nil
      ) do |url|
        unless url.nil?
          @grid_url = url.to_s
          halting_assert('Grid URL given must look like a Selenium Grid '\
                         'registration URL') do
            @grid_url.end_with?('/wd/hub')
          end
        end
      end

      # Flag for specifying the timeouts when locating elements in the DOM.
      TIMEOUT_FLAG = make_flag(
        :timeout,
        description: 'Timeout duration (in seconds) for browser activity',
        default: 20
      ) do |timeout|
        @timeout = timeout.to_i
        ::PageObject.default_page_wait = @timeout
        ::PageObject.default_element_wait = @timeout
        ::Watir.default_timeout = @timeout
      end

      # For now, we're using the setup-execute-teardown pattern.
      def self.phases
        super + [
          Ladon::Automator::Phase.new(:setup, required: true),
          Ladon::Automator::Phase.new(:execute,
                                      required: true,
                                      validator: ->(a) { a.result.success? }),
          Ladon::Automator::Phase.new(:teardown, required: true)
        ]
      end

      # Builds the +Ladon::Watir::WebAppFiniteStateMachine+ that will represent
      # the web application, with states as page objects and transitions driven
      # by browser navigation.
      #
      # @return [Ladon::Watir::WebAppFiniteStateMachine] The finite state
      #   machine that will power the automation.
      def build_model
        @browser = self.build_browser
        @screenshots = {}
        self.model = Ladon::Watir::WebAppFiniteStateMachine.new(@browser)
      end

      # Create an instance of the Watir::Browser. Depending on the flags given
      # to this automation, supports spawning the browser either locally or via
      # any standard Selenium Grid instance.
      def build_browser
        self.handle_flag(BROWSER_FLAG)
        self.handle_flag(GRID_URL_FLAG)
        self.handle_flag(TIMEOUT_FLAG)

        return local_browser if @grid_url.nil?

        self.handle_flag(PLATFORM_FLAG)
        return remote_browser
      end

      # The first phase of the automation.
      # Processes the class' defined browser setup flags, configuring the
      # browser appropriately.
      def setup
        self.handle_flag(HEIGHT_FLAG)
        self.handle_flag(WIDTH_FLAG)
        @browser.window.move_to(0, 0)
        self.handle_flag(UI_URL_FLAG)
      end

      # The last phase of the automation. Quits the browser.
      def teardown
        @browser.quit

        self.result.record_data('screenshots', @screenshots)
      end

      # Resize the browser's width to the given value.
      #
      # @param [Integer] width Should be the desired width of the browser, in
      # number of pixels.
      #   May be the constant value +FULL_SCREEN_SIZE+ to indicate to maximize
      #   available width.
      def browser_width=(width)
        width = browser.screen_width if width == FULL_SCREEN_SIZE
        browser.window.resize_to(width.to_i, browser.window.size.height)
      end

      # Resize the browser's height to the given value.
      #
      # @param [Integer] height Should be the desired height of the browser, in
      #   number of pixels.
      #   May be the constant value +FULL_SCREEN_SIZE+ to indicate to maximize
      #   available height.
      def browser_height=(height)
        height = browser.screen_height if height == FULL_SCREEN_SIZE
        browser.window.resize_to(browser.window.size.width, height.to_i)
      end

      # Take a screenshot of the current appearance of the browser instance.
      #
      # NOTE: Timing is important when using this method. For example, if you
      # request a screenshot immediately after submitting a form, you may get a
      # shot of a blank page if there is dynamic content loading (e.g., via
      # XHR).
      #
      # @param [String] name Title to associate with the screenshot that will
      #   be taken.
      def screenshot(name)
        begin
          @screenshots[name] = @browser.screenshot.base64
        rescue => ex
          @logger.warn("Unable to take screenshot '#{name}' due to an error "\
                       "(#{ex.class}: #{ex})")
        end
      end

      private

      # Constructs a browser to be driven locally.
      # @return [Ladon::Watir::Browser] The new browser object.
      def local_browser
        return Ladon::Watir::Browser.new_local(type: @browser_type)
      end

      # Constructs a browser to be driven remotely on a grid.
      # @return [Ladon::Watir::Browser] The new browser object.
      def remote_browser
        return Ladon::Watir::Browser.new_remote(url: @grid_url,
                                                type: @browser_type,
                                                platform: @platform)
      end

      # Loads the url passed in a new browser tab.
      #
      # @param [String] url The url to be loaded in the new browser
      #   tab.
      def load_browser_tab(url:)
        @browser.execute_script('window.open()')
        @browser.windows.last.use
        @browser.goto(url)
      end

      # Switches to the desired browser tab based on the tab position passed.
      #
      # @param [Integer] position The tab position to be switched.
      def switch_browser_tab(position:)
        @browser.windows[position - 1].use
        @browser.execute_script('window.alert()')
        @browser.alert.close if @browser.alert.present?
      end

      # Closes the browser tab based on the tab position passed.
      #
      # @param [Integer] position The tab position to be closed.
      def close_browser_tab(position:)
        @browser.windows[position - 1].close
      end
    end
  end
end
