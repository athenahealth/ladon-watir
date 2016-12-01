require 'rspec'
require 'simplecov'
require 'watir'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

class FakeWatirBrowser < Watir::Browser
  def initialize
    # Intentionally does not call `super` to avoid setting up a bridge.
  end

  def goto(_url); end

  def quit; end
end
