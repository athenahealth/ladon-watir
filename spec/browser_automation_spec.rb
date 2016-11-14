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
      auto = ExampleBrowserAutomation.new(config)
      auto.instance_variable_set(:@browser, FakeWatirBrowser.new)

      return auto
    end

    context 'called with default config' do
      let(:config) { Ladon::Automator::Config.new }

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
        Ladon::Automator::Config.new(flags: {
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

      it { is_expected.to be_an_instance_of(Ladon::Automator::Result) }

      it 'should have a successful run' do
        expect(subject).to be_a_success
      end
    end
  end
end
