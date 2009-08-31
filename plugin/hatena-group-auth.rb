# hatena-group-auth.rb
# Copyright (C) rosylilly and sorah

require "hiki/session"
require "auth/hatenagroup_auth"

@conf["hatega.api_key"] ||=""
@conf["hatega.sec_key"] ||=""
@conf["hatega.group_name"] ||=""
@conf["hatega.login_message"] ||="login to hatena-group"

def hatena_group_instance
    if (@conf["hatega.api_key"].empty? || @conf["hatega.sec_key"].empty? || @conf["hatega.group_name"].empty?)
        return "Setting first please." 
    end
    begin
        return HatenaGroup.new(@conf["hatega.group_name"],@conf["hatega.api_key"],@conf["hatega.sec_key"])
    rescue HatenaGroup::GroupNotFound
        return "Group not found"
    end
end


def auth?
    return true if @user && !@conf.password.empty?
    return true if @conf["hatega.api_key"].empty?
    session_id = @cgi.cookies["auth_hatega_session_id"][0]
    session_id && Session::new( @conf, session_id ).check
end

def auth_user
    session_id = @cgi.cookies["auth_hatega_session_id"][0]
    session = Session::new( @conf, session_id ) if session_id
	session && session.check && session.user
end

def auth_hatega
    ha = hatena_group_instance
    return ha unless ha.kind_of?(HatenaGroup)

    session_id = @cgi.cookies["auth_hatega_session_id"][0]
    session = Session::new( @conf, session_id ) if session_id
    type = @cgi.params["type"][0]
    if type == "out"
        session.delete if session
        redirect(@cgi, "#{@conf.cgi_name}")
    else
        cert = @cgi.params["cert"][0]
        return "cert required" unless cert
        user = ha.get_user(cert)
        if user
            if ha.member?(user.name)
                session = Session::new(@conf)
                session.user = user.name
                session.save
                self.cookies << CGI::Cookie.new( "auth_hatega_session_id", session.session_id )
            else
                session.delete if session
                return "you are not a member of the hatena-group #{CGI::escapeHTML(@conf["hatega.group_name"])}."
            end
        else
            session.delete if session
        end
        page = @cgi.params["p"][0] || "FrontPage"
        redirect(@cgi, "#{@conf.cgi_name}?#{CGI::escape(page)}", self.cookies)
    end
end

def hatega_login_url(page_name)
    ha = hatena_group_instance
    return nil unless ha.kind_of?(HatenaGroup)
    return ha.login_url(:p => page_name)
end

def hatega_logout_url
    @conf.cgi_name+"?c=plugin&plugin=auth_hatega&type=out"
end

def hatega_callback_url
    "http://#{@cgi.host}#{ENV["REQUEST_URI"].sub(/\?.+$/,"")}?c=plugin&plugin=auth_hatega"
end


add_body_enter_proc do
    if @conf["hatega.api_key"].empty? || @conf["hatega.sec_key"].empty? || @conf["hatega.group_name"].empty?
        "<div class=\"hello\">Setting first</div>"
    elsif !auth?
       "<div class=\"hello\">#{@conf["hatega.login_message"].sub(/login/,"<a href=\""+hatega_login_url(@page)+"\">login</a>").sub(/groupname/,CGI::escapeHTML(@conf["hatega.group_name"]))}</div>"
    elsif user = auth_user
        @user = user
        "<div class=\"hello\">Hello #{@user.escapeHTML} - <a href=\"#{hatega_logout_url}\">logout</a></div>"
    end
end

add_conf_proc( "auth_hatega", "Hatena group auth" ) do
	if @mode == "saveconf" then
		@conf["hatega.api_key"] = @cgi.params["hatega.api_key"][0]
		@conf["hatega.sec_key"] = @cgi.params["hatega.sec_key"][0]
        @conf["hatega.group_name"] = @cgi.params["hatega.group_name"][0]
        @conf["hatega.login_message"] = @cgi.params["hatega.login_message"][0]
	end
	<<-HTML
    <h3 class="subtitle">hatena-group name</h3>
    <p>Input hatena-group name.  http:// *group-name* .g.hatena.ne.jp/</p>
    <p><input name="hatega.group_name" size="50" value="#{CGI::escapeHTML(@conf["hatega.group_name"])}"></p>
    <h3 class="subtitle">header message</h3>
    <p>Input not-login message</p>
    <p>login => login link groupname => group-name</p>
    <p><input name="hatega.login_message" size="50" value="#{CGI::escapeHTML(@conf["hatega.login_message"])}"></p>
	<h3 class="subtitle">API key</h3>
	<p>api key. <a href="http://auth.hatena.ne.jp/">auth.hatena.ne.jp page</a></p>
    <p>callback url #{CGI::escapeHTML(hatega_callback_url)}</p>
	<p><input name="hatega.api_key" size="50" value="#{CGI::escapeHTML(@conf["hatega.api_key"])}"></p>
	<h3 class="subtitle">secret key</h3>
	<p>secret key <a href="http://auth.hatena.ne.jp/">auth.hatena.ne.jp page</a></p>
    <p>Callback url #{CGI::escapeHTML(hatega_callback_url)}</p>
	<p><input name="hatega.sec_key" size="50" value="#{CGI::escapeHTML(@conf["hatega.sec_key"])}"></p>
	HTML
end
