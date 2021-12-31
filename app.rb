require "fileutils"
require "warden"
require "sinatra"
require "rmagick"
require "mimemagic"
require "digest/md5"
require "sass"
require "rack-protection"
require "rack/attack"

require_relative "controller.rb"

Warden::Strategies.add(:password) do
  def valid?
    params["user"] && params["user"]["username"] && params["user"]["password"]
  end

  def authenticate!
    user = User.find_by_username(params["user"]["username"])
    unless user == nil
      if user.password == params["user"]["password"]
        success!(user)
      else
        puts "here"
        throw(:warden, message: "The username and password combination ")
      end
    else
      throw(:warden, message: "The username and password combination ")
    end
  end
end

class GemChan < Sinatra::Application
  set :root, Dir.pwd
  configure do
    ChanController::init()
  end
  session_key = SecureRandom.hex(64)
  enable :sessions
  set :session_secret, session_key

  use Rack::Protection
  use Rack::Attack

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  use Rack::Session::Cookie, :key => "rack.session",
                             :path => "/",
                             :secret => session_key
  Rack::Attack.safelist("allow from localhost") do |req|
    # Requests are allowed if the return value is truthy
    "127.0.0.1" == req.ip || "::1" == req.ip
  end
  Rack::Attack.throttle("requests by ip", limit: 4, period: 1) do |request|
    if request.path == "/reply" || request.path == "/create_op"
      puts request.ip
      request.ip
    end
  end
  if ChanController.configurations[:recaptcha] == true
    Recaptcha.configure do |config|
      config.site_key = ChanController.configurations[:recaptcha_site_key]
      config.secret_key = ChanController.configurations[:recaptcha_secret_key]
    end
    include Recaptcha::Adapters::ControllerMethods
    include Recaptcha::Adapters::ViewMethods
  end

  use Warden::Manager do |config|
    config.serialize_into_session { |user| user.id }
    config.serialize_from_session { |id| User.find(id) }

    config.scope_defaults :default, strategies: [:password], action: "auth/unauthenticated"
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end
  Warden::Manager.before_failure do |env, opts|
    # Because authentication failure can happen on any request but
    # we handle it only under "post '/auth/unauthenticated'", we need
    # to change request to POST
    env["REQUEST_METHOD"] = "POST"
    # And we need to do the following to work with  Rack::MethodOverride
    env.each do |key, value|
      env[key]["_method"] = "post" if key == "rack.request.form_hash"
    end
  end

  #css
  get "/style.scss" do
    scss :style
  end
end

require_relative "routes/routes.rb"
require_relative "model.rb"
