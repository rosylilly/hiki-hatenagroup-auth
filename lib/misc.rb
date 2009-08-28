def convert_ary_to_hash(ary)
    if ary.kind_of?(Array)
        return Hash[*ary]
    else
        raise ArgumentError,"ary is Array"
    end
end
