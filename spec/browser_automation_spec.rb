require 'byebug'
require 'rspec'
require 'ladon-watir/browser_automation'
require 'ladon-watir/page_object_state'

class ExamplePageObjectState < PageObjectState
  def self.model_html(metaclass)
    metaclass.h1(:header)
  end
end

class ExampleBrowserAutomation < WatirBrowserAutomation
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
    def model.selection_strategy(transition_options)
      return transition_options[0] unless transition_options.size != 1
    end
    model.use_state_type(ExamplePageObjectState, strategy: Ladon::Modeler::LoadStrategy::EAGER)
  end

  def execute
    byebug
    header.eq? 'Example Domain'
  end
end

RSpec.describe WatirBrowserAutomation do
  describe '#run' do
    target_automation_class = ExampleBrowserAutomation;
    target_automation = target_automation_class.spawn()
    target_automation_class.all_phases.each_with_index do |phase_name, idx|
      target_automation.run(to_index: idx) # this is the interesting line
    end
  end
end
