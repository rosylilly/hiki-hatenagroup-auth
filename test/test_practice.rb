require 'lib/misc.rb'

class TestConvertAryToHash < Test::Unit::TestCase
    def test_convert_ary_to_hash
        assert_raise(ArgumentError) do
            convert_ary_to_hash([1,2,3,4,5])
        end
        assert_raise(ArgumentError) do
            convert_ary_to_hash([1,2,3])
        end
        assert_kind_of(Hash,convert_ary_to_hash([1,2,3,4]))
    end
end

