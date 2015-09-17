
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
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1"})

      # All is there ?
      assert_equal 0, server.componentsCount
    end
  end

  def test_incidents
    VCR.use_cassette("incidents") do
      server = Rcachet::Server.new({base_uri: "http://localhost:8080", api_version: "v1"})

      # All is there ?
      assert_equal 0, server.incidentsCount
    end
  end
end
