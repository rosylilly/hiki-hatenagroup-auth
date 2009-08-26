# target class
class Foo
  def initialize
    @bar = "bar"
  end
  attr_reader :bar

  def sample(arg)
    raise(ArgumentError,'invalid arg type') unless arg.kind_of?(String)

    return arg.length > 5 ? true : false
  end
end

class TestFoo < Test::Unit::TestCase
  def setup
    @obj = Foo.new
  end

  def test_bar
    assert_equal("bar", @obj.bar)
  end

  def test_sample
    assert_raise(ArgumentError) do
      @obj.sample(1)
    end

    assert_nothing_raised() do
      @obj.sample('')
    end

    assert(@obj.sample("123456"))
    assert(!@obj.sample("123"))
  end
end
