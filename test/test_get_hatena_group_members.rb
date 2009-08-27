class TestGetHatenaGroupMembers < Test::Unit::TestCase
    def test_argument
        assert_raise(ArgumentError) do
            get_hatena_group_members([])
        end
        assert_nothing_raised() do
            get_hatena_group_members('generation1991')
        end
    end

    def test_type
        assert_kind_of(String,get_hatena_group_members('generation1991'))
    end
end
