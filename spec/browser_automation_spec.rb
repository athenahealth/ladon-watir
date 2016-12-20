require 'rspec'
require 'ladon'
require 'ladon/watir/browser_automation'

class ExampleBrowserAutomation < Ladon::Watir::BrowserAutomation
  # Assertion message for header verification
  HEADER_MSG = 'Header must say "Example Domain"'.freeze

  def self.default_url
    'http://example.com'
  end

  def default_browser
    :chrome
  end

  def default_platform
    :windows
  end

  def self.abstract?
    false
  end

  def local_browser(*)
    FakeWatirBrowser.new
  end

  # Our automation verifies that the page's header says 'Example Domain'.
  # Normally that would look like this:
  #   `model.current_state.header.eql? 'Example Domain'`
  # But since this is a test of BrowserAutomation in relative isolation, we'll
  # pretend the assertion holds.
  def execute
    assert(HEADER_MSG) { true }
  end
end

# Define a matcher for the Ladon::Automator::Result that calling an
# automation's +run+ method returns. This matcher verifies that the
# Result indicates a successful outcome.
RSpec::Matchers.define :be_a_success do
  match do |actual|
    puts actual
    return actual.success?
  end
end

RSpec.describe Ladon::Watir::BrowserAutomation do
  describe '#setup' do
    let(:automation) do
      auto = ExampleBrowserAutomation.new(config: config)
      auto.instance_variable_set(:@browser, FakeWatirBrowser.new)

      return auto
    end

    context 'called with default config' do
      let(:config) { Ladon::Config.new }

      subject { automation }

      it 'should call setup methods with default arguments' do
        allow(subject).to receive(:browser_height=) {}
        allow(subject).to receive(:browser_width=) {}
        allow(subject.browser).to receive(:goto) {}

        subject.setup

        expect(subject).to have_received(:browser_height=)
          .with(ExampleBrowserAutomation::FULL_SCREEN_SIZE)
        expect(subject).to have_received(:browser_width=)
          .with(ExampleBrowserAutomation::FULL_SCREEN_SIZE)
        expect(subject.browser).to have_received(:goto)
          .with('http://example.com')
      end
    end

    context 'called with custom config' do
      let(:config) do
        Ladon::Config.new(flags: {
                            width: 100,
                            height: 100,
                            ui_url: 'http://zombo.com'
                          })
      end

      subject { automation }

      it 'should call setup methods with custom arguments' do
        allow(subject).to receive(:browser_height=) {}
        allow(subject).to receive(:browser_width=) {}
        allow(subject.browser).to receive(:goto) {}

        subject.setup

        expect(subject).to have_received(:browser_height=).with(100)
        expect(subject).to have_received(:browser_width=).with(100)
        expect(subject.browser).to have_received(:goto).with('http://zombo.com')
      end
    end
  end

  describe '#screenshot' do
    let(:config) { Ladon::Config.new(log_level: :WARN) }

    let(:automation) do
      auto = ExampleBrowserAutomation.new(config: config)

      allow(auto).to receive(:build_browser) { FakeWatirBrowser.new }
      auto.build_model

      return auto
    end

    it 'should take screenshots and store them in the result' do
      allow(automation.browser).to receive(:screenshot) do
        fake_screenshot_class = Class.new do
          def base64
            'fake base64 encoded screenshot'
          end
        end

        fake_screenshot_class.new
      end

      automation.screenshot('first screenshot')
      automation.screenshot('second screenshot')

      automation.teardown

      expect(automation.result.data_log['screenshots'])
        .to eql('first screenshot' => 'fake base64 encoded screenshot',
                'second screenshot' => 'fake base64 encoded screenshot')
    end

    context 'when @browser.screenshot throws an exception' do
      it 'should log a warning' do
        allow(automation.browser).to receive(:screenshot) do
          raise 'Something went horribly wrong'
        end

        automation.screenshot('first screenshot')
        automation.screenshot('second screenshot')

        automation.teardown

        warnings = automation.result.logger.entries.map do |entry|
          entry.msg_lines[0] if entry.level.eql?(:WARN)
        end.compact

        expect(warnings).to include(
          "Unable to take screenshot 'first screenshot' due to an error "\
          '(RuntimeError: Something went horribly wrong)'
        )
        expect(warnings).to include(
          "Unable to take screenshot 'second screenshot' due to an error "\
          '(RuntimeError: Something went horribly wrong)'
        )
      end
    end
  end

  describe '#run' do
    context 'when run against example.com' do
      let(:automation) do
        auto = ExampleBrowserAutomation.spawn
        auto.instance_variable_set(:@browser, FakeWatirBrowser.new)

        return auto
      end

      subject do
        allow(automation).to receive(:browser_height=) {}
        allow(automation).to receive(:browser_width=) {}

        automation.run
      end

      it { is_expected.to be_an_instance_of(Ladon::Result) }

      it 'should have a successful run' do
        expect(subject).to be_a_success
      end
    end
  end
end
