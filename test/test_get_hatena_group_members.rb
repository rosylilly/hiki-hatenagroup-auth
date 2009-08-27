require "lib/hatena_group.rb"
class TestGetHatenaGroupMembers < Test::Unit::TestCase
    def test_get_hatena_group_members
        assert_raise(ArgumentError) do
            get_hatena_group_members([])
        end
        
        assert_raise(ArgumentError) do
            get_hatena_group_members("sonzaisinayoaaaaajfiwea")
        end

        assert_nothing_raised() do
            get_hatena_group_members('generation1991')
        end

        assert_kind_of(Array,get_hatena_group_members('generation1991'))
    end
end
