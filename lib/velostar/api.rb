
require 'net/http'

module VeloStar
  class Api
    def initialize key
      @key = key
    end
    def getstation
      uri_str = "http://data.keolis-rennes.com/xml/?version=1.0&key=#{@key}&cmd=getstation"
      uri = URI.parse( uri_str )
      res = Net::HTTP.get_response( uri )
      return res.body
    end
  end
end
