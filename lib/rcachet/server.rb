require 'faraday'
require 'json'

module Rcachet
  class Server

    # TODO: revoir le choix "attr_accessor" car ils ne sont aps vraiment appellé à l'exterieur
    attr_accessor :base_uri, :api_version, :components, :incidents

    def initialize(attributes)
      @base_uri    = attributes[:base_uri]
      @api_version = attributes[:api_version]
      @components  = nil
      @incidents   = nil
    end

    def ping
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/ping")
      attributes = JSON.parse(response.body)

      attributes["data"]
    end

    def componentsCount
      if !@components then
        cachetGetComponents
      end
      @components["meta"]["pagination"]["count"]
    end

    def incidentsCount
      if !@incidents then
        cachetGetIncidents
      end
      @incidents["meta"]["pagination"]["count"]
    end

    private

    # get from cachet server
    def cachetGetComponents
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/components")
      @components = JSON.parse(response.body)
    end

    def cachetGetIncidents
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/incidents")
      @incidents = JSON.parse(response.body)
    end
  end
end
