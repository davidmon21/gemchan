require 'sinatra'

module Gemchan
    Warden::Strategies.add(:password) do
        def valid?
          params['user'] && params['user']['username'] && params['user']['password']
        end
    
        def authenticate!
            user = User.find_by_username(params['user']['username'])
            unless user == nil
                if user.password == params['user']['password']
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
    class Server < Sinatra::Base

        configure do
            Gemchan::ChanController::init( )
        end

        enable :sessions
        set :session_secret, "supersecret"

        use Warden::Manager do |config|
            config.serialize_into_session{ |user| user.id }
            config.serialize_from_session{ |id| User.find(id) }

            config.scope_defaults :default, strategies: [:password], action: 'auth/unauthenticated'
            # When a user tries to log in and cannot, this specifies the
            # app to send the user to.
            config.failure_app = self
        end
        Warden::Manager.before_failure do |env,opts|
            # Because authentication failure can happen on any request but
            # we handle it only under "post '/auth/unauthenticated'", we need
            # to change request to POST
            env['REQUEST_METHOD'] = 'POST'
            # And we need to do the following to work with  Rack::MethodOverride
            env.each do |key, value|
              env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
            end
        end

        get '/auth/login' do
            erb :login
        end
        
        post '/auth/login' do
            env['warden'].authenticate!
        
            if session[:return_to].nil?
              redirect '/'
            else
              redirect session[:return_to]
            end
        end
        
        get '/auth/logout' do
            env['warden'].raw_session.inspect
            env['warden'].logout
            redirect '/'
        end

        post '/auth/unauthenticated' do
            session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
        
            # Set the error and use a fallback if the message is not defined
            
            redirect '/auth/login'
        end

        ##session and authentication needed for below

        get '/manage' do
            env['warden'].authenticate!
            erb :admin
        end

        get '/manage/:board' do
            env['warden'].authenticate!
            if Gemchan::ChanController::boards_dict.has_key? '/'+params[:board]
                erb :adminboard
            else
                erb :page_not_found
            end
        end

        post '/delete' do
            env['warden'].authenticate!
            Gemchan::ChanController::delete_post(params)
            redirect back
        end

        post '/createboard' do
            env['warden'].authenticate!
            Gemchan::ChanController::createboard(params)
            Gemchan::ChanController::update_boards_dict
            redirect back
        end

        post '/reply' do
            Gemchan::ChanController::create_post(params)
            redirect back
        end

        post '/create_op' do
            Gemchan::ChanController::create_post(params, is_op=true)
            redirect back
        end

        post '/delete' do
            Gemchan::ChanController::delete_post(params)
            redirect back
        end

        get '/' do
            erb :index 
        end
        
        get '/*/*/?' do |route, op|
            if Gemchan::ChanController::boards_dict.has_key? '/'+route
                if Op.exists?(post_id: op)
                    @op = op
                    @bid, @posts = Gemchan::ChanController::thread_page_data(@op, '/'+route)
                    erb :thread
                else 
                    erb :page_not_found
                end
            end
        end

        get '/*/?' do |route|
            if Gemchan::ChanController::boards_dict.has_key? '/'+route
                @page_data = Gemchan::ChanController::board_page_data('/'+route)
                @route = '/'+route
                erb :board
            else
                erb :page_not_found
            end
        end
    end
end
