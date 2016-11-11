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
      attr_reader :browser

      # Create a new instance of this class.
      def initialize(browser)
        @browser = browser
        super()

        # set up metaclass to facilitate page-object modeling
        _page_object_class_workaround

        # run this class' HTML modeling on the metaclass for instance safety
        self.class.model_html(singleton_class)
      end

      # Every +PageObjectState+ must model the HTML elements available on the
      # page it models; this method should be used to do so.
      #
      # @param [Class] The class the model will be effected upon.
      #   When creating instances, this will be the +singleton_class+
      #   of the instance being created.
      #
      # We write our HTML model method in context of the target class
      # This is because page-object only supports class-level modeling.
      #
      # Our PageObject-style States really want to have instance-level
      # modeling, since each instance may be created under different context
      # in-ruby-process, and we don't want them conflicting.
      #
      # So, we're using this approach so we can put our HTML modeling on the
      # per-instance singleton class of each PageObjectState instance.
      def self.model_html(_target_class)
        raise Ladon::MissingImplementationError, 'self.model_html'
      end

      private

      # This is necessary to work around the class-level modeling design
      # of the page-object gem.
      #
      # @private
      def _page_object_class_workaround
        # include PageObject on the metaclass
        singleton_class.send(:include, PageObject)

        # Hack in the PageObject initializer
        initialize_browser(browser)
      end
    end
  end
end
