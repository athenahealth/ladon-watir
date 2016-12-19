require 'ladon/watir'

# Represents the search results page of youtube.com at /results.
class YouTubeResultsPage < Ladon::Watir::PageObjectState
  div(:results, id: 'results')

  def self.transitions
    [
      Ladon::Modeler::Transition.new do |t|
        t.target_loader { require 'models/page_objects/watch' }
        t.target_identifier { YouTubeWatchPage }
        t.by(&:select_result)
      end
    ]
  end

  def find_result(title:)
    @desired_result_element = self.results_element.when_present.link_element(
      title: title
    )
  end

  def select_result
    @desired_result_element.click
  end
end
