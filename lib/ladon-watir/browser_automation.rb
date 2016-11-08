require 'ladon'
require 'watir-webdriver'

require 'ladon-watir/page_object_state'

class WatirBrowserAutomation < Ladon::Automator::ModelAutomation
  attr_reader :browser

  NO_GRID_DEFAULT = :NONE
  OS_FLAG = :os
  GRID_URL_FLAG = :grid_url
  URL_FLAG = :ui_url
  BROWSER_FLAG = :browser

  def build_model
    grid_url = flags.get(GRID_URL_FLAG, default_to: NO_GRID_DEFAULT)
    browser_type = flags.get(URL_FLAG, default_to: default_browser).to_sym
    platform = flags.get(URL_FLAG, default_to: default_platform).to_sym

    if grid_url == NO_GRID_DEFAULT
      @browser = Watir::Browser.new(browser_type)
    else
      caps = Selenium::WebDriver::Remote::Capabilities.send(browser_type)
      caps.platform = platform

      @client = Selenium::WebDriver::Remote::Http::Default.new

      # Increase timeout to 20 minutes to allow queued tests to process when grid resources free up.
      @client.timeout = 60 * 20 # seconds

      @browser = Watir::Browser.new(
          :remote,
          url: grid_url.to_s,
          desired_capabilities: caps,
          http_client: @client
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

  def setup
    @browser.goto(flags.get(URL_FLAG, default_to: default_url))
  end

  def teardown
    @browser.quit
  end
end
