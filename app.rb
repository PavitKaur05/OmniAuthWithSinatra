require 'sinatra'
require 'omniauth'
require 'omniauth-gitlab'
require 'omniauth-twitter'

configure do
    set :sessions, true
end

use OmniAuth::Builder do
    if development?
      provider :developer,
               fields: [:name],
               uid_field: :name
    end
    # Configure GitLab OAuth provider
    provider :gitlab, 'YOUR_GITLAB_CLIENT_ID', 'YOUR_GITLAB_CLIENT_SECRET',
    scope: "read_user",
    client_options: {
      site: 'https://salsa.debian.org/api/v4/'
    }
    
    # Configure Twitter OAuth provider
    provider :twitter, 'YOUR_TWITTER_CLIENT_ID', 'YOUR_TWITTER_CLIENT_SECRET'
end

OmniAuth.config.on_failure = proc do |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

OmniAuth.config.logger.level = Logger::UNKNOWN

get '/login' do
    <<~HTML
    <form method='post' action='/auth/gitlab'>
    <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
    <button type='submit'>Login with Salsa</button>
    </form>
    <form method='post' action='/auth/twitter'>
    <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
    <button type='submit'>Login with Twitter</button>
    </form>
    <form method='post' action='/auth/developer'>
    <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
    <button type='submit'>Login with Developer</button>
    </form>
  HTML
end

get '/auth/:provider/callback' do
    erb "
    <h1>Hello #{request.env['omniauth.auth']['info']['name']}</h1>"
end

post '/auth/developer/callback' do
    erb "
    <h1>Hello #{request.env['omniauth.auth']['info']['name']}</h1>"
end

get '/auth/failure' do
    halt(403, erb("<h2>Authentication Failed</h2><h4>Reason: </h4><pre>#{params[:message]}</pre>"))
end