def test_convert_ary_to_hash
    begin
        convert_ary_to_hash([1,2,3,4,5])
    rescue ArgumentError
        return true if convert_ary_to_hash([1,2,3,4]).kind_of?(Hash)
    end
end
p test_convert_ary_to_hash 
