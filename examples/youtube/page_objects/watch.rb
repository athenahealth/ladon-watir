require 'ladon/watir'

# Represents the video watching page of youtube.com at /watch.
class YouTubeWatchPage < Ladon::Watir::PageObjectState
  def self.transitions
    []
  end

  def self.model_html(_metaclass)
  end
end
