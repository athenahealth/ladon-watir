require 'ladon'
require 'watir-webdriver'
require 'ladon-watir/page_object_state'

# Base class for all Watir WebDriver-based browser automation.
#
# @abstract
#
# @attr_reader [Watir::Browser] browser The Watir WebDriver browser object.
class WatirBrowserAutomation < Ladon::Automator::ModelAutomation
  attr_reader :browser

  NO_GRID_DEFAULT = :NONE
  OS_FLAG = :os
  GRID_URL_FLAG = :grid_url
  URL_FLAG = :ui_url
  BROWSER_FLAG = :browser

  # Builds the +Ladon::Modeler::FiniteStateMachine+ that will represent the web
  # application, with states as page objects and transitions driven by browser
  # navigation.
  #
  # @return [Ladon::Modeler::FiniteStateMachine] The finite state machine that
  #   will power the automation.
  def build_model
    grid_url = flags.get(GRID_URL_FLAG, default_to: NO_GRID_DEFAULT)
    browser_type = flags.get(URL_FLAG, default_to: default_browser).to_sym
    platform = flags.get(URL_FLAG, default_to: default_platform).to_sym

    if grid_url == NO_GRID_DEFAULT
      @browser = local_browser(type: browser_type)
    else
      @browser = remote_browser(
        url: grid_url,
        type: browser_type,
        platform: platform
      )
    end

    self.model = Ladon::Modeler::FiniteStateMachine.new
    self.model.instance_variable_set('@browser', @browser)

    def model.valid_state?(state_class)
      super && state_class < PageObjectState
    end

    def model.new_state_instance(state_class)
      @current_state = state_class.new(@browser)
    end
  end

  # The first phase of the automation. Navigates to the starting URL.
  def setup
    @browser.goto(flags.get(URL_FLAG, default_to: default_url))
  end

  # The last phase of the automation. Quits the browser.
  def teardown
    @browser.quit
  end

  # Constructs a browser to be driven locally.
  #
  # @private
  # @return [Watir::Browser] The new browser object.
  def local_browser(type:)
    return Watir::Browser.new(type)
  end

  # Constructs a browser to be driven remotely on a grid.
  #
  # @private
  # @return [Watir::Browser] The new browser object.
  def remote_browser(url:, type:, platform:)
    capabilities = Selenium::WebDriver::Remote::Capabilities.send(type)
    capabilities.platform = platform

    @client = Selenium::WebDriver::Remote::Http::Default.new

    # Increase timeout to 20 minutes to allow queued tests to process when grid
    # resources free up.
    @client.timeout = 60 * 20 # seconds.

    return Watir::Browser.new(
      :remote,
      url: url.to_s,
      desired_capabilities: capabilities,
      http_client: @client
    )
  end
end
