require 'ladon/watir/modeler/page_object_state'
require 'ladon/watir/modeler/custom_widget'

class SpecWidget < Ladon::Watir::CustomWidget
  def self.tag_name
    return 'login_widget'
  end

  def self.parent_type
    return PageObject::Elements::Div
  end

  def self.root_element
    return 'div'
  end

  def widget_setup
    @did_setup = true
  end
end

class POStateMock
  def browser
    2
  end
end

RSpec.describe Ladon::Watir::CustomWidget do
  describe '#new' do
    let(:po_state) { POStateMock.new }
    subject { SpecWidget.new(1, po_state) }

    it { is_expected.to have_attributes(element: 1, browser: 2) }

    it 'has an instance variable referencing the page object state it was instantiated with' do
      expect(subject.instance_variable_get(:@page_object_state)).to eq(po_state)
    end

    it 'triggers widget_setup' do
      expect(subject.instance_variable_get(:@did_setup)).to be true
    end
  end

  describe '.tag_name' do
    subject { -> { Ladon::Watir::CustomWidget.tag_name } }

    it { is_expected.to raise_error(StandardError) }
  end

  describe '.root_element' do
    subject { -> { Ladon::Watir::CustomWidget.root_element } }

    it { is_expected.to raise_error(StandardError) }
  end

  describe '.parent_type' do
    subject { -> { Ladon::Watir::CustomWidget.parent_type } }

    it { is_expected.to raise_error(StandardError) }
  end

  describe '.register_with_page_object' do
    subject { -> { SpecWidget.register_with_page_object } }

    it 'registers the custom widget with Page-Object' do
      expect(PageObject).to receive(:register_widget)
      subject.call
    end
  end

  describe '.custom_widget_types' do
    subject { Ladon::Watir::CustomWidget.custom_widget_types }

    it { is_expected.to be_an_instance_of(Array) }

    it { is_expected.to include(SpecWidget) }
  end
end
