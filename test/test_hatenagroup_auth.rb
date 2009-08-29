require 'lib/hatenagroup_auth'

class TestHatenaGroupAuth < Test::Unit::TestCase
  def setup
    @obj = HatenaGroup.new('generation1991', 'api_key', 'sec_key')
  end

  def test_initialize
    assert_equal('generation1991', @obj.group_name)
    assert_equal('http://generation1991.g.hatena.ne.jp/', @obj.group_url)

    assert_raise(HatenaGroup::GroupNotFound) do
      HatenaGroup.new('notfoundnotfoundnotfound', 'api_key', 'sec_key')
    end
  end

  def test_generater
    assert_instance_of?(String, @obj.login_url)
  end
end
