require 'faraday'
require 'json'

module Rcachet
  class Server

    # TODO: revoir le choix "attr_accessor" car ils ne sont aps vraiment appellé à l'exterieur
    attr_accessor :base_uri, :api_version, :components, :incidents, :metrics, :subscribers, :api_token

    def initialize(attributes)
      @base_uri    = attributes[:base_uri]
      @api_version = attributes[:api_version]
      @components  = nil
      @incidents   = nil
      @metrics     = nil
      @subscribers = nil
      @api_token   = attributes[:api_token] ? attributes[:api_token] : nil
    end

    # Test that cachet is up
    # @return 'Pong!'
    def ping
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/ping")
      attributes = JSON.parse(response.body)

      attributes["data"]
    end

    # Returns the number of components
    # @return
    def componentsCount
      if !@components
        cachetGetComponents
      end
      @components["meta"]["pagination"]["count"]
    end

    def componentAdd(component)
      cachetSecurePut("components", component)
    end

    # return the components values in JSON
    # @return JSON
    def componentGetById(componentId)
      component = cachetGetComponentById(componentId)
    end

    def incidentsCount
      if !@incidents
        cachetGetIncidents
      end
      @incidents["meta"]["pagination"]["count"]
    end

    # get the full json of an incident
    # @return JSON
    def incidentsGetById(incidentId)
      incident = cachetGetIncidentById(incidentId)
    end

    # add a new incident
    # @return incident ID
    def incidentsAdd(newIncident)
      cachetSecurePut('incidents', newIncident)
    end

    def metricsCount
      if !@metrics
        cachetGetMetrics
      end
      @metrics["meta"]["pagination"]["count"]
    end

    def subscribersCount
      if !@subscribers
        cachetGetSubscribers
      end
      @subscribers["meta"]["pagination"]["count"]
    end

    private

    # get from cachet server
    def cachetGetComponents
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/components")
      @components = JSON.parse(response.body)
    end

    # get one component
    def cachetGetComponentById(componentId)
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/components/#{componentId}")
      component = JSON.parse(response.body)
    end

    def cachetGetIncidents
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/incidents")
      @incidents = JSON.parse(response.body)
    end

    # return the full json of an incident Id
    # @return JSON
    def cachetGetIncidentById(incidentId)
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/incidents/#{incidentId}")
      incident = JSON.parse(response.body)
    end

    def cachetGetMetrics
      response = Faraday.get("#{@base_uri}/api/#{@api_version}/metrics")
      @metrics = JSON.parse(response.body)
    end

    def cachetGetSubscribers
      response = cachetSecureAccess "subscribers"
      @subscribers = JSON.parse(response.body)
    end

    def cachetSecureAccess(component)
      response = Faraday.get do |req|
        req.url "#{@base_uri}/api/#{@api_version}/#{component}"
        req.headers['Content-Type']   = 'application/json'
        req.headers['X-Cachet-Token'] = @api_token
      end
    end

    def cachetSecurePut(component, attributes)
      success = false

      conn = Faraday.new(:url => "#{@base_uri}")

      response = conn.post do |req|
        req.url "/api/#{@api_version}/#{component}"
        req.headers['Content-Type']   = 'application/json'
        req.headers['X-Cachet-Token'] = @api_token
        req.body                      = attributes.to_json
      end

      responseData = JSON.parse(response.body)
      if response.status == 200
        success = responseData['data']['id']
      end

      return success
    end
  end
end
