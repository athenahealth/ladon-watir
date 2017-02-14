require 'ladon/watir/modeler/page_object_state'

module Ladon
  module Watir
    # Class that facilitates definition of custom widgets that model custom HTML elements.
    # NOTE: you *must* register the custom widget with page-object for your page object states to use it. See
    # the +register_with_page_object+ method.
    class CustomWidget
      attr_reader :element, :browser

      # Creates a new instance of the custom widget class.
      # * Arguments:
      #   - +selenium_element+:: The Selenium element actually representing the root HTML element of this custom widget.
      #   - +page_object_state+:: Reference to the +PageObjectState+ instance this widget is being used by at runtime.
      def initialize(selenium_element, page_object_state)
        @element = selenium_element
        @page_object_state = page_object_state
        @browser = page_object_state.browser
        widget_setup
      end

      # Called by widget constructor to facilitate per-widget custom configuration without having to override the
      # initialize method and deal with the "under the hood" stuff.
      # Default implementation is a no-op.
      def widget_setup; end

      # Method that should return the "tag" name for this custom element, for use within PageObjects for modeling this
      # widget. For example, let's say you have a "UI Toolkit" that has a custom checkbox in it. This method, then,
      # might return "ui_toolkit_checkbox".
      #
      # Then, Page Objects could declare that they a UI Toolkit checkbox on the page, e.g.:
      #   ui_toolkit_checkbox(:my_checkbox, id: 'some-id', frame: some-frame)
      #
      # * Returns:
      #   - A snake-cased string that identifies the method Page Objects can use to leverage this widget.
      #
      # * Raises:
      #   - StandardError if subclass doesn't define this method.
      def self.tag_name
        raise StandardError, "#{self.name} must implement 'self.tag_name'!"
      end

      # Method that should return the "tag" name for this custom element, for use within PageObjects for modeling this
      # widget.
      #
      # For example, let's say you have a "UI Toolkit" that has a custom checkbox in it.
      # This method, then, might return "ui_toolkit_checkbox".
      #
      # Then, Page Objects could declare that they a UI Toolkit checkbox on the page, e.g.:
      #   ui_toolkit_checkbox(:my_checkbox, id: 'some-id', frame: some-frame)
      #
      # * Returns:
      #   - A lowercase string identifying the root HTML element (e.g., 'div') of this custom widget.
      #
      # * Raises:
      #   - StandardError if subclass doesn't define this method.
      def self.root_element
        raise StandardError, "#{self} must implement 'self.root_element'!"
      end

      # In the page-object gem, when we define a custom widget, we need to tell page-object which of its element types
      # most adequately describes what our custom widget tries to be.
      #
      # For example, if you have a custom widget that is trying to be a table, you would want this method to return the
      # page-object element for table (which happens to be PageObject::Elements::Table).
      #
      # * Returns:
      #   - Nothing currently. Should return a reference to the relevant PageObject::Elements::<TYPE> for this widget.
      def self.parent_type
        raise StandardError, "#{self} must implement 'self.parent_type'!"
      end

      # Identifies the list of all loaded Ladon custom widgets.
      # @return [Array<Class>] List of CustomWidget subclass implementations.
      def self.custom_widget_types
        ObjectSpace.each_object(CustomWidget.singleton_class).to_a - [CustomWidget]
      end

      # Register this CustomWidget implementation with +PageObject+ so that it can be used by +PageObjectState+s.
      def self.register_with_page_object
        PageObject.register_widget(self.safe_tag_name, self.build_element_class, self.safe_root_element)

        # TODO: follow up with page-object maintainers to determine if we can fix this jankiness
        PageObjectState.send :include, PageObject
      end

      # Get the +tag_name+ for this Widget class, doing basic validation to ensure the returned value is acceptable.
      #
      # * Returns:
      #   - String identifying the new "tag" that may be used by Page Objects to model instances of this custom Widget.
      #
      # * Raises:
      #   - StandardError if the +tag_name+ has a space in it; calling a method with a whitespace in it would be...hard.
      def self.safe_tag_name
        tag_name = self.tag_name
        raise StandardError, "Invalid tag_name value: #{tag_name}" if tag_name =~ /\s/
        return tag_name
      end

      # Get the +root_element+ value for this Widget class, making a best effort attempt at formatting the value
      # in the form that PageObject's +register_widget+ expects.
      #
      # * Returns:
      #   - A symbol identifying an HTML element tag that acts as the root element for instances of this widget.
      def self.safe_root_element
        return self.root_element.to_sym.downcase
      end

      # NOTE: disabling method length cop for +build_element_class+ because I don't see a good way to cut it down more.
      # rubocop:disable Metrics/MethodLength

      # In the page-object gem, "custom widgets" have to be subclasses of page-object modeling elements, such as
      # PageObject::Elements::Table. Custom widget authors shouldn't have to deal with this boilerplate, so we
      # automatically build an anonymous subclass based on the custom widget definition and let the author(s) focus
      # on their actual widget implementation.
      def self.build_element_class
        new_element = Class.new(self.parent_type) do
          # This method is a hook into the page-object library. We implement this so that whenever a PageObjectState
          # models an HTML element using a custom widget, each Page Object instance automatically gets a method for
          # accessing an instance of the +CustomWidget+ extension for interacting with that element.
          def self.accessor_methods(accessor, name)
            w_class = self.instance_variable_get('@widget_class')
            accessor.send(:define_method, name.to_s) do
              elem = self.instance_variable_get("@#{name}_impl")
              if elem.nil? # if "#{name}" hasn't been called before, create a new widget and cache it for next time
                elem = w_class.new(self.send("#{name}_element"), self)
                self.instance_variable_set("@#{name}_impl", elem)
              end
              elem # return the custom widget instance
            end
          end
        end
        new_element.instance_variable_set('@widget_class', self) # Anonymous class tracks the Ladon widget it wraps
        Object.const_set("#{self.name}ElementImpl", new_element) # Register and name the new class with Ruby
        return new_element
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
