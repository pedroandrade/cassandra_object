require 'test_helper'

class CassandraObject::BaseTest < CassandraObject::TestCase
  class Son < CassandraObject::Base
  end

  class Grandson < Son
  end

  test 'base_class' do
    assert_equal CassandraObject::Base, CassandraObject::Base
    assert_equal Son, Son.base_class
    assert_equal Son, Grandson.base_class
  end

  test 'column family' do
    assert_equal 'CassandraObject::BaseTest::Sons', Son.column_family
    assert_equal 'CassandraObject::BaseTest::Sons', Grandson.column_family
  end

  test 'hex_to_text' do
    assert_equal "9a52b386c3ab46e22c8fe7fc1f0686b8b4fd072e", CassandraObject::Base.hex_to_text('39613532623338366333616234366532326338666537666331663036383662386234666430373265')
  end
end
