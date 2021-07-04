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
    provider :gitlab, '4449f80c89e8b7c09e4a361a0e52503029e548d0712153b397b77d78b22f8a7b' ,'1605a64014de0488470013c5d09c4b25b4a1124fa1eed3138f4b90706efcbfd7' ,
             scope: "read_user",
             client_options: {
               site: 'https://salsa.debian.org/api/v4/'
             }
    provider :twitter, 'yuCLCftKbkc0SzytIpiCdLvaW', 'Tbw6LfeV24bdg29ODfKBkiEmPRb6SJlyhRqsz0P1e63WM1j9ft'
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