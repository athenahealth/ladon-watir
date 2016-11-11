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
  def default_url
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

  def build_model
    super

    model.use_state_type(
      ExamplePageObjectState,
      strategy: Ladon::Modeler::LoadStrategy::EAGER
    )
  end

  def execute
    self.model.current_state.header.eql? 'Example Domain'
  end
end

RSpec::Matchers.define :be_a_success do
  match do |actual|
    return actual.result.success?
  end
end

# RSpec.describe Ladon::Watir::BrowserAutomation do
#   describe '#run' do
#     context 'Run against example.com' do
#       target_automation_class = ExampleBrowserAutomation
#       target_automation = target_automation_class.spawn

#       subject { target_automation }

#       target_automation_class.all_phases.each_with_index do |_phase_name, idx|
#         target_automation.run(to_index: idx)
#       end

#       it { is_expected.to be_a_success }
#     end
#   end
# end
