def convert_ary_to_hash(ary)
    if ary.kind_of?(Array) && ary.length % 2 == 0
        return Hash[*ary]
    else
        raise ArgumentError,"invaid argument"
    end
end
