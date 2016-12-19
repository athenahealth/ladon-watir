require 'ladon'
require 'ladon/watir'

# Represents the main page of youtube.com.
class YouTubeIndexPage < Ladon::Watir::PageObjectState
  text_field(:search, id: 'masthead-search-term')
  button(:submit_search, id: 'search-btn')

  def self.transitions
    [
      Ladon::Modeler::Transition.new do |t|
        t.target_loader { require 'models/page_objects/results' }
        t.target_identifier { YouTubeResultsPage }
        t.when { |page| !page.search.empty? }
        t.by(&:execute_search)
      end
    ]
  end

  def enter_search(term:)
    self.search_element.when_present
    self.search = term
  end

  def execute_search
    self.submit_search
  end
end
