require 'ladon/watir'

# Represents the search results page of youtube.com at /results.
class YouTubeResultsPage < Ladon::Watir::PageObjectState
  def self.transitions
    [
      Ladon::Modeler::Transition.new do |t|
        t.to_load_target_state_type { require_relative 'watch' }
        t.to_identify_target_state_type { YouTubeWatchPage }
        # t.when { true }
        t.by(&:select_result)
      end
    ]
  end

  def self.model_html(metaclass)
    metaclass.div(:results, id: 'results')
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
