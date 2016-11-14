require 'ladon/watir/page_object_state'

class ExamplePageObjectState < Ladon::Watir::PageObjectState
  def self.transitions
    []
  end

  def self.model_html(metaclass)
    metaclass.h1(:header)
    metaclass.h2(:case_1_sub_header) if @@test_case == 1
    metaclass.h2(:case_2_sub_header) if @@test_case == 2
  end
end

RSpec.describe Ladon::Watir::PageObjectState do
  describe '#new' do
    let(:page_object_state_1) do
      ExamplePageObjectState.class_variable_set(:@@test_case, 1)
      ExamplePageObjectState.new(FakeWatirBrowser.new)
    end

    let(:page_object_state_2) do
      ExamplePageObjectState.class_variable_set(:@@test_case, 2)
      ExamplePageObjectState.new(FakeWatirBrowser.new)
    end

    context 'when instance is created first' do
      subject do
        object = page_object_state_1
        page_object_state_2

        return object
      end

      it { is_expected.to respond_to :header }
      it { is_expected.to respond_to :header_element }
      it { is_expected.to respond_to :case_1_sub_header }
      it { is_expected.to respond_to :case_1_sub_header_element }
      it { is_expected.not_to respond_to :case_2_sub_header }
      it { is_expected.not_to respond_to :case_2_sub_header_element }
    end

    context 'when instance is created second' do
      subject do
        page_object_state_2
        page_object_state_1
      end

      it { is_expected.to respond_to :header }
      it { is_expected.to respond_to :header_element }
      it { is_expected.to respond_to :case_1_sub_header }
      it { is_expected.to respond_to :case_1_sub_header_element }
      it { is_expected.not_to respond_to :case_2_sub_header }
      it { is_expected.not_to respond_to :case_2_sub_header_element }
    end
  end
end
