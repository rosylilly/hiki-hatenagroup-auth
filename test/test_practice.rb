def test_convert_ary_to_hash
    begin
        convert_ary_to_hash([1,2,3,4,5])
    rescue ArgumentError
        return true if convert_ary_to_hash([1,2,3,4]).kind_of?(Hash)
    end
end

class TestConvertAryToHash < Test::Unit::TestCase
    def test_exception
        assert_raise(ArgumentError) do
            convert_ary_to_hash([1,2,3,4,5])
        end
    end
    def test_type
        assert_kind_of(Hash,convert_ary_to_hash([1,2,3,4]))
    end
end

