
class RcachetServerTest < Minitest::Test
  def test_all_my_class_exists
    assert Rcachet::Server
  end

  def test_it_answered_pong_to_my_ping
    VCR.use_cassette('pingpong') do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1"})
      assert_equal 'Pong!', server.ping
    end
  end

  def test_my_internals
    server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1"})

    # What am I ?
    assert_equal Rcachet::Server, server.class

    # Do I work well ?
    assert_equal "http://localhost:8080", server.base_uri
    assert_equal "v1",                    server.api_version
  end

  def test_components
    VCR.use_cassette('components') do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1", api_token: "SZGlZQOnG4gz1sGtua1Y"})

      component = {name: "component_1",
                   description: "description component 1",
                   status: 1
      }

      # All is there ?
      assert_equal 0, server.componentsCount
      assert_equal 1, server.componentAdd(component)

      # Test if the first component (id = 1) is there and equal to my "component"
      assert_equal "1", server.componentGetById("1")["data"]["id"]
      assert_equal "component_1", server.componentGetById("1")["data"]["name"]
      assert_equal "description component 1", server.componentGetById("1")["data"]["description"]
      assert_equal "1", server.componentGetById("1")["data"]["status"]

    end
  end

  def test_incidents
    VCR.use_cassette("incidents") do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1", api_token: "SZGlZQOnG4gz1sGtua1Y"})

      incidentTest = {
                        name: 'incident_01',
                        message: 'message_incident_01',
                        status: 1,
                        visible: 1,
                        notify: false
      }

      # All is there ?
      assert_equal 0, server.incidentsCount

      # Add an incident
      assert_equal 1, server.incidentsAdd(incidentTest)

      # Get incident N°1
      assert_equal 'incident_01',         server.incidentsGetById('1')['data']['name']
      assert_equal 'message_incident_01', server.incidentsGetById('1')['data']['message']
      assert_equal '1',                     server.incidentsGetById('1')['data']['status']
      assert_equal 1,                     server.incidentsGetById('1')['data']['visible']

    end
  end

  def test_metrics
    VCR.use_cassette("metrics") do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1"})

      # All is there ?
      assert_equal 0, server.metricsCount
    end
  end

  def test_subscribers
    VCR.use_cassette("subscribers") do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1", api_token: "SZGlZQOnG4gz1sGtua1Y"})

      # All is there ?
      assert_equal 0, server.subscribersCount
    end
  end
end
