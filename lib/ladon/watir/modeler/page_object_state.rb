require 'ladon'
require 'page-object'
require 'ladon/watir'

module Ladon
  module Watir
    # Represents a state in a web-based user interface.
    # Requires the use of the page-object gem for HTML modeling, and
    # can be used to automate the UI being modeled, via a Watir browser.
    #
    # Models the features the page exposes and the transitions available from
    # instances of this PageObjectState to other PageObjectStates.
    #
    # Various page types should inherit from this class and define any
    # methods that are marked as abstract.
    #
    # @abstract
    #
    # @attr_reader [Watir::Browser] browser A Watir-WebDriver browser instance.
    class PageObjectState < Ladon::Modeler::State
      include PageObject

      attr_reader :browser

      # Create a new instance of this class.
      def initialize(browser)
        @browser = browser

        super
      end

      # Called at the end of PageObject#initialize. Sets up instance-level HTML
      # modeling methods.
      def initialize_page
        instance_model_html(singleton_class)
      end

      # Defines HTML modeling methods that may vary per-instance of this class.
      #
      # @param [Class] _target_class The class the model will be effected upon.
      #   When creating instances, this will be the +singleton_class+
      #   of the instance being created.
      #
      # Because page-object only supports class-level modeling, we write
      # instance-level HTML model methods in context of the target class.
      #
      # Some PageObject-style States really want to have instance-level
      # modeling, since each instance may be created under different context
      # in-ruby-process, and we don't want them conflicting.
      #
      # So, we're using this approach so we can put our HTML modeling on the
      # per-instance singleton class of each PageObjectState instance.
      def instance_model_html(_target_class); end
    end
  end
end
