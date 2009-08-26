def test_convert_ary_to_hash
    begin
        ary = [1,2,3,4,5]
        if ary.length % 2 == 0
            hash = Hash[*ary]
        else
            raise ArgumentError, "argument error: not even-numbered ary.length"
        end
    rescue ArgumentError
        ary = [1,2,3,4]
        if ary.length % 2 == 0
            hash = Hash[*ary]
        else
            raise ArgumentError, "argument error: not even-numbered ary.length"
        end
        return true if hash.kind_of?(Hash)
    end
end
p test_convert_ary_to_hash 
