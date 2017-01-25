require 'ladon/watir'

# Represents the search results page of youtube.com at /results.
class YouTubeResultsPage < Ladon::Watir::PageObjectState
  div(:results, id: 'results')

  transition 'YouTubeWatchPage' do |t|
    t.target_loader { require 'models/page_objects/watch' }
    t.by(&:select_result)
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
