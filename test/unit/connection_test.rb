require 'test_helper'

class CassandraObject::ConnectionTest < CassandraObject::TestCase
  class TestObject < CassandraObject::Base
  end

  test 'establish_connection' do
    TestObject.establish_connection(
      access_key_id: 'foo',
      secret_access_key: 'bar'
    )

    assert_equal 'foo', TestObject.connection.config.access_key_id
    assert_equal 'bar', TestObject.connection.config.secret_access_key
    # assert_not_equal CassandraObject::Base.connection, TestObject.connection
    # assert_equal 'place_directory_development', TestObject.connection.keyspace
    # assert_equal ["192.168.0.100:9160"], TestObject.connection.servers
    # assert_equal 10, TestObject.connection.thrift_client_options[:timeout]
  end

  # test 'establish_connection defaults' do
  #   TestObject.establish_connection(
  #     access_key_id: 'foo',
  #     secret_access_key: 'bar'
  #   )
  #   
  #   assert_equal 'place_directory_development', TestObject.connection.config
  #   assert_equal ["127.0.0.1:9160"], TestObject.connection.servers
  # end
end