require 'rspec'
require 'ladon'
require 'ladon/watir/browser_automation'
require 'ladon/watir/page_object_state'

class ExamplePageObjectState < Ladon::Watir::PageObjectState
  def self.transitions
    []
  end

  def self.model_html(metaclass)
    metaclass.h1(:header)
  end
end

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

  # Build the model as specified in +BrowserAutomation+, then load a starting
  # page into the model and make it the current model state.
  #
  # This implementation uses the model for the example.com home page.
  def build_model
    super

    model.use_state_type(
      ExamplePageObjectState,
      strategy: Ladon::Modeler::LoadStrategy::EAGER
    )
  end

  # Our automation verifies that the page's header says 'Example Domain'
  def execute
    assert(HEADER_MSG) { model.current_state.header.eql? 'Example Domain' }
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
  describe '#run' do
    context 'when run against example.com' do
      let(:automation) { ExampleBrowserAutomation.spawn }
      subject { automation.run }

      it { is_expected.to be_an_instance_of(Ladon::Automator::Result) }

      # Commenting this out for now. This will fail if chromedriver is not
      # installed in the test environment.
      # TODO: Mock depenencies to make this more of a true unit test.
      # it { is_expected.to be_a_success }
    end
  end
end
