require 'ladon/watir/modeler/web_app_finite_state_machine'
require 'ladon/watir/modeler/page_object_state'

class ExamplePageObjectState < Ladon::Watir::PageObjectState
end

RSpec.describe Ladon::Watir::WebAppFiniteStateMachine do
  let(:web_app_fsm) do
    Ladon::Watir::WebAppFiniteStateMachine.new(
      FakeWatirBrowser.new
    )
  end

  describe '#valid_state?' do
    context 'given a subclass of Ladon::Watir::PageObjectState' do
      let(:valid_state_class) { ExamplePageObjectState }

      subject { web_app_fsm.valid_state?(valid_state_class) }

      it { is_expected.to be_truthy }
    end

    context 'given Ladon::Watir::PageObjectState' do
      let(:invalid_state_class) { Ladon::Watir::PageObjectState }

      subject { web_app_fsm.valid_state?(invalid_state_class) }

      it { is_expected.to be_falsey }
    end

    context 'given an ancestor of Ladon::Watir::PageObjectState' do
      let(:invalid_state_class) { Object }

      subject { web_app_fsm.valid_state?(invalid_state_class) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#new_state_instance' do
    context 'given ExamplePageObjectState' do
      subject do
        web_app_fsm.new_state_instance(ExamplePageObjectState)
        web_app_fsm.instance_variable_get(:@current_state)
      end

      it { is_expected.to be_an_instance_of ExamplePageObjectState }
    end
  end

  describe '#selection_strategy' do
    context 'given an empty list' do
      let(:transition_options) { [] }

      subject { web_app_fsm.selection_strategy(transition_options) }

      it { is_expected.to be_nil }
    end

    context 'given a single-element list' do
      let(:transition) { Ladon::Modeler::Transition.new }
      let(:transition_options) { [transition] }

      subject { web_app_fsm.selection_strategy(transition_options) }

      it { is_expected.to be transition }
    end

    context 'given a two-element list' do
      let(:transition_options) do
        [
          Ladon::Modeler::Transition.new,
          Ladon::Modeler::Transition.new
        ]
      end

      subject { web_app_fsm.selection_strategy(transition_options) }

      it { is_expected.to be_nil }
    end
  end
end
