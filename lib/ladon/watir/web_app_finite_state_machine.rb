require 'ladon'
require 'ladon/watir/page_object_state'

module Ladon
  module Watir
    # Represents a web application as a finite state machine, with page objects
    # representing states.
    class WebAppFiniteStateMachine < Ladon::Modeler::FiniteStateMachine
      def valid_state?(state_class)
        super && state_class < Ladon::Watir::PageObjectState
      end

      def new_state_instance(state_class)
        @current_state = state_class.new(@browser)
      end

      def selection_strategy(transition_options)
        return transition_options[0] unless transition_options.size != 1
      end
    end
  end
end
