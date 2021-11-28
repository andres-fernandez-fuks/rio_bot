require 'faraday'
require 'uri'

class ApiFiubak
  def initialize(url)
    raise StandardError unless url =~ URI::DEFAULT_PARSER.make_regexp

    @url = url
  end
end
