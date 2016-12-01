require 'ladon'
require 'ladon/watir'

# Represents the main page of youtube.com.
class YouTubeIndexPage < Ladon::Watir::PageObjectState
  def self.transitions
    [
      Ladon::Modeler::Transition.new do |t|
        t.to_load_target_state_type { require 'models/page_objects/results' }
        t.to_identify_target_state_type { YouTubeResultsPage }
        t.when { |page| !page.search.empty? }
        t.by(&:execute_search)
      end
    ]
  end

  def self.model_html(metaclass)
    metaclass.text_field(:search, id: 'masthead-search-term')
    metaclass.button(:submit_search, id: 'search-btn')
  end

  def enter_search(term:)
    self.search_element.when_present
    self.search = term
  end

  def execute_search
    self.submit_search
  end
end
