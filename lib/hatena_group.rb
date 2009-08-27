require "open-uri"
def get_hatena_group_members(group_id)
    raise ArgumentError,"group_id is string" unless group_id.kind_of?(String)

    html = open("http://#{group_id}.g.hatena.ne.jp/diarylist") do |f|
        if f.base_uri.to_s == "http://g.hatena.ne.jp/"
            raise ArgumentError,"hatena group \"#{group_id}\" not exist"
        else
            f.read
        end
    end 
    ary = []
    ary << html.scan(/<a href="\/(\w+)\/"><img class="hatena-id-icon/)
    
    while /<a rel="next" href="diarylist\?of=([0-9]+)" class="next">/ =~ html
        html = open("http://#{group_id}.g.hatena.ne.jp/diarylist?of=#{$1}"){|f|f.read}
        ary << html.scan(/<a href="\/(\w+)\/"><img class="hatena-id-icon/)
    end
    
    return ary.flatten
end
