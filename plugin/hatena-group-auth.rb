# hatena-group-auth.rb
# Copyright (C) rosylilly and sorah

require 'hiki/session'
require 'auth/hatenagroup_auth'

@conf['hatega.api_key'] ||= ''
@conf['hatega.sec_key'] ||= ''
@conf['hatega.group_name'] || = ''
@conf['hatega.login_message'] ||= 'はてなグループにログイン'
def hatena_group_instance
    return "Setting first please." if @conf['hatega.api_key'].empty? || @conf['hatega.sec_key'].empty? || @conf['hatega.group_name'].empty?
    begin
        return HatenaGroup.new(@conf['hatega.group_name'],@conf['hatega.api_key'],@conf['hatega.sec_key'])
    rescue HatenaGroup::GroupNotFound
        return "Group not found"
    end
end


def auth?
    return true if @user && !@conf.password.empty?
    return true if @conf['hatega.api_key'].empty?
    session_id = @cgi.cookies['auth_hatega_session_id'][0]
    session_id && Session::new( @conf, session_id ).check
end

def auth_user
    session_id = @cgi.cookies['auth_hatega_session_id'][0]
    session = Session::new( @conf, session_id ) if session_id
	session && session.check && session.user
end

def auth_hatega
    ha = hatena_group_instance
    return ha unless ha.kind_of?(HatenaGroup)

    session_id = @cgi.cookies['auth_hatega_session_id'][0]
    session = Session::new( @conf, session_id ) if session_id
    type = @cgi.params['type'][0]
    if type == 'out'
        session.delete if session
        redirect(@cgi, "#{@conf.cgi_name}")
    else
        cert = @cgi.params['cert'][0]
        return "cert required" unless cert
        user = ha.get_user(cert)
        if user
            if ha.member?(user.name)
                session = Session::New(@conf)
                session.user = user.name
                session.save
                self.cookies << CGI::Cookies.new( 'auth_hatega_session_id', session.session_id )
            else
                session.delete if session
                return "you are not a member of the hatena-group #{CGI::escapeHTML(@conf['hatega.group_name'])}."
            end
        else
            session.delete if session
        end
        page = @cgi.params['p'][0] || 'FrontPage'
        redirect(@cgi, "#{@conf.cgi_name}?#{CGI::escape(page)}", self.cookies)
    end
end

def hatega_login_url(param = {})
    ha = hatena_group_instance
    return nil unless ha.kind_of?(HatenaGroup)
    return ha.login_url(param)
end

def hatega_logout_url
    "#{@conf.cgi_name}?c=plugin;plugin=auth_hatega;type=out"
end

add_body_enter_proc do
    return "" if @conf['hatega.api_key'].empty? || @conf['hatega.sec_key'].empty? || @conf['hatega.group_name'].empty?

    unless auth?
        <<-HTML
        <div class="hello">
        #{@conf['hatega.login_message'].gsub(/ログイン/,'<a href="'+hatega_login_url(:p => @page)+'">ログイン</a>').gsub(/groupname/,CGI::escapeHTML(@conf["hatega.group_name"]))}
        </div>
        HTML
    elsif user = auth_user
        @user = user
        <<-HTML
        <div class="hello">
        こんにちは、#{@user.escapeHTML}さん - <a href="#{hetaga_logout_url}">ログアウト</a>
        </div>
        HTML
    end
end

add_conf_proc( 'auth_hatega', 'はてな認証' ) do
	if @mode == 'saveconf' then
		@conf['hatena.api_key'] = @cgi.params['hatena.api_key'][0]
		@conf['hatena.secret_key'] = @cgi.params['hatena.secret_key'][0]
	end
	<<-HTML
    <h3 class="subtitle">はてなグループ名</h3>
    <p>はてなグループ名を入力してください。グループ名はURLの http://これ.g.hatena.ne.jp/ です</p>
    <p><input name="hatega.group_name" size="50" value="#{CGI::escapeHTML(@conf['hatega.group_name'])}"></p>
    <h3 class="subtitle">ログインメッセージ</h3>
    <p>ログインしていないときに表示するメッセージを設定します。</p>
    <p>なお、ログインはログイン画面へのリンク、groupnameはグループ名に置換されます。</p>
    <p><input name="hatega.login_message" size="50" value="#{CGI::escapeHTML(@conf['hatega.login_message'])}"></p>
	<h3 class="subtitle">API キー</h3>
	<p>API キーを指定します。API キーは、<a href="http://auth.hatena.ne.jp/">はてな認証APIのページ</a>で取得できます。</p>
    <p>はてな認証API設定のコールバックURLは、「#{CGI::escape(hatega_callback_uri)}」を指定してください。</p>
	<p><input name="hatega.api_key" size="50" value="#{CGI::escapeHTML(@conf['hatega.api_key'])}"></p>
	<h3 class="subtitle">秘密鍵</h3>
	<p>秘密鍵を指定します。秘密鍵は、<a href="http://auth.hatena.ne.jp/">はてな認証APIのページ</a>で取得できます。</p>
    <p>APIのコールバックURLは、「#{CGI::escape(hatega_callback_uri)}」を指定してください。</p>
	<p><input name="hatega.sec_key" size="50" value="#{CGI::escapeHTML(@conf['hatega.sec_key'])}"></p>
	HTML
end
