require 'open-uri'
require 'uri'
require 'rexml/document'
require 'digest/md5'
class HatenaGroup
  def initialize(group_id, api_key, secret_key)
    @group_id = group_id
    @api_key = api_key
    @secret_key = secret_key
    u = open("http://#{@group_id}.g.hatena.ne.jp/")
    raise GroupNotFound, "`g:#{@group_id}' is not found" if u.base_uri.to_s == "http://g.hatena.ne.jp/"
  end

  def group_name
    @group_id
  end

  def group_url
    "http://#{@group_id}.g.hatena.ne.jp/"
  end

  def api_sig(hash)
    Digest::MD5.hexdigest("#{@secret_key}" + hash.to_a.sort{|a,b| a[0].to_s <=> b[0].to_s }.map{|k,v| "#{k.to_s}#{v.to_s}"}.to_s)
  end

  def hash_to_query(hash)
    hash.to_a.map{|k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join('&')
  end

  def login_url(hash=nil)
    raise ArgumentError if hash.nil? and !hash.instance_of?(Hash)
    if hash.nil?
    "http://auth.hatena.ne.jp/auth?api_key=#{@api_key}&api_sig=#{api_sig(:api_key => @api_key)}"
    else
        hash[:api_key] = @api_key
"http://auth.hatena.ne.jp/auth?#{hash_to_query(hash)}"+"&api_sig=#{api_sig(hash)}"
    end
  end

  def get_user(cert)
    xml = nil
    begin
      xml = open("http://auth.hatena.ne.jp/api/auth.xml?#{hash_to_query(:api_key => @api_key, :cert => cert, :api_sig => api_sig(:api_key => @api_key, :cert => cert))}").read
      xml = REXML::Document.new(xml)
    rescue
      return false
    end
    elms = xml.elements
    if elms['/response/has_error'].text == 'true'
      return false
    end
    return User.new(:name => elms['/response/user/name'].text, :image => elms['/response/user/image_url'].text, :thumbnail => elms['/response/user/thumbnail_url'].text)
  end

  class User
    def initialize(hash)
      @name = hash[:name]
      @image = hash[:image]
      @thumbnail = hash[:thumbnail]
    end
    attr_reader :name, :image, :thumbnail
  end

  class GroupNotFound < Exception
  end
end

if $0 == __FILE__
  HatenaGroup.new("notfound", "api_key", "secret_key")
end
