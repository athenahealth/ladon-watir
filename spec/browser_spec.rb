require 'watir'
require 'ladon/watir/browser'

RSpec.describe Ladon::Watir::Browser do
  describe '.new_local' do
    it 'constructs a new local browser' do
      # Stub the WebDriver class so that we don't create a bridge.
      web_driver = class_double('Selenium::WebDriver').as_stubbed_const
      allow(web_driver).to receive(:for) {}

      local_browser = Ladon::Watir::Browser.new_local(type: :chrome)

      expect(local_browser).to be_a_kind_of(::Watir::Browser)
    end
  end

  describe '.new_remote' do
    it 'constructs a new remote browser' do
      # Stub the WebDriver class so that we don't create a bridge.
      web_driver = class_double('Selenium::WebDriver')
                   .as_stubbed_const

      allow(web_driver).to receive(:for) {}

      # Stub other dependencies, now that they are going to be nested in a
      # stubbed module.
      capabilities = class_double('Selenium::WebDriver::Remote::Capabilities')
                     .as_stubbed_const

      allow(capabilities).to receive(:send) {}

      fake_remote_http_default = instance_double(
        'Selenium::WebDriver::Remote::Http::Default'
      )

      expect(fake_remote_http_default).to receive(:open_timeout=).with(1200)
      expect(fake_remote_http_default).to receive(:read_timeout=).with(1200)

      remote_http_default = class_double(
        'Selenium::WebDriver::Remote::Http::Default'
      ).as_stubbed_const

      allow(remote_http_default).to receive(:new) { fake_remote_http_default }

      remote_browser = Ladon::Watir::Browser.new_remote(
        url: 'http://example.com',
        type: :chrome,
        platform: :macosx
      )

      expect(remote_browser).to be_a_kind_of(::Watir::Browser)
    end
  end

  describe '#screen_height' do
    it 'gets the screen height' do
      # Stub the WebDriver class so that we don't create a bridge.
      web_driver = class_double('Selenium::WebDriver').as_stubbed_const
      allow(web_driver).to receive(:for) {}

      local_browser = Ladon::Watir::Browser.new_local(type: :chrome)

      expect(local_browser).to receive(:execute_script)

      local_browser.screen_height
    end
  end

  describe '#screen_width' do
    it 'gets the screen width' do
      # Stub the WebDriver class so that we don't create a bridge.
      web_driver = class_double('Selenium::WebDriver').as_stubbed_const
      allow(web_driver).to receive(:for) {}

      local_browser = Ladon::Watir::Browser.new_local(type: :chrome)

      expect(local_browser).to receive(:execute_script)

      local_browser.screen_width
    end
  end
end
