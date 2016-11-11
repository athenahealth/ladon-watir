require 'ladon'
require 'page-object'

module Ladon
  module Watir
    # Represents a state in a web-based user interface.
    # Models the features exposed by and the transitions available from
    # instances of this State class.
    #
    # @attr_reader [Watir::Browser] browser The Watir WebDriver browser object.
    class PageObjectState < Ladon::Modeler::State
      attr_reader :browser

      def initialize(browser)
        @browser = browser
        super()

        _setup_page_object_nonsense
        self.class.model_html(singleton_class)
      end

      def self.model_html
        # We write our HTML model method in context of the target class
        # This is because page-object only supports class-level modeling.
        #
        # Our PageObject-style States really want to have instance-level
        # modeling, since each instance may be created under different context
        # in-ruby-process, and we don't want them conflicting.
        #
        # So, we're using this approach so we can put our HTML modeling on the
        # per-instance singleton class of each PageObjectState instance.
        raise Ladon::MissingImplementationError, 'self.model_html'
      end

      # This is necessary to work around the class-level modeling design flaw in
      # page-object.
      #
      # @private
      def _setup_page_object_nonsense
        singleton_class.send(:include, PageObject)
        self.initialize_browser(browser) # Shortcut the PageObject initializer.
      end
    end
  end
end
