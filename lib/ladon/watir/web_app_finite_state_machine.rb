require 'ladon'
require 'ladon/watir/page_object_state'

module Ladon
  module Watir
    # Represents a web application as a finite state machine, with page objects
    # representing states.
    class WebAppFiniteStateMachine < Ladon::Modeler::FiniteStateMachine
      # Creates a new instance.
      #
      # @param [Watir::Browser] browser The browser that will run
      #   the model's implementation code.
      # @param [Ladon::Modeler::Config] config The object providing
      #   configuration for this new Graph model.
      #
      # @return [FiniteStateMachine] The new graph instance.
      def initialize(browser, config = Ladon::Config.new)
        @browser = browser
        super(config: config)
      end

      # Determine if the given +state_class+ is a valid state type.
      # In our implementation, state types must be PageObjectState subclasses.
      #
      # @return True if +state_class+ is a PageObject state and thus valid in
      #   this machine, else false.
      def valid_state?(state_class)
        super && state_class < Ladon::Watir::PageObjectState
      end

      # To create instances of our PageObjectStates, we need to override the
      # default implementation so that it gives the browser instance to the
      # state, as required by the page-object gem.
      #
      # @param [Class] state_class State type to instantiate.
      # @return Instance of +state_class+ when given a single browser arg.
      def new_state_instance(state_class)
        @current_state = state_class.new(@browser)
      end

      # In our default implementation, we only select a transition if there
      # is only one option available.
      #
      # @param [Array<Ladon::Modeler::Transition>] transition_options The list
      #   of available transitions that can be selected.
      # @return A single Transition instance from the given option set.
      #   If there is not a single option available, returns nil.
      def selection_strategy(transition_options)
        return transition_options[0] unless transition_options.size != 1
      end
    end
  end
end
