require 'net/http'
require 'uri'

class Utils

  def self.curl_get(url)
    begin
      uri = URI.parse(url)
    rescue URI::InvalidURIError
      uri = URI.parse(URI.escape(url))
    end
      return Net::HTTP.get(uri)
    end

end
