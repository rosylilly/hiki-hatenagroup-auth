def convert_ary_to_hash(ary)
    if ary.length % 2 == 0
        return Hash[*ary]
    else
        raise ArgumentError, "argment error: not even-numbered ary.length"
    end
end

def check_exception
    begin
        convert_ary_to_hash([1,2,3,4,5])
    rescue ArgumentError
        true
    end
end
def check_type
    convert_ary_to_hash([1,2,3,4]).kind_of?(hash)
end
p check_exception
p check_type
