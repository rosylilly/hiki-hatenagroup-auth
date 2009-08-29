require 'auth/hatenagroup_auth'

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
    assert(@obj.login_url(:var => 'test') =~ /var=test/)
  end

  def test_members
    assert_instance_of?(Array, @obj.members)
  end

  def test_member?
    assert(@obj.member?('rosylilly'))
  end

  def test_get_user
    assert_instance_of?(HatenaGroup::User, @obj.cert('cert'))
  end

  def test_user
    user = @obj.get_user('cert')

    assert_instance_of?(String, user.name)
    assert_instance_of?(String, user.image)
    assert_instance_of?(String, user.thumbnail)
  end
end
