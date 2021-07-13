require 'sinatra'
require 'securerandom'
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
        set :root, Dir.pwd
        configure do
            Gemchan::ChanController::init( )
        end
        session_key = SecureRandom.hex(64)
        enable :sessions
        set :session_secret, session_key
        use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => session_key

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
        get '/style.scss' do
            scss :style
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

        post '/admin_post' do
            env['warden'].authenticate!
            Gemchan::ChanController::create_admin_post(params)
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

        get '/*/page/*' do |route,pagenumber|
            puts "matched"
            puts route
            puts pagenumber
            pagenumber = pagenumber.to_i
            if Gemchan::ChanController::boards_dict.has_key? '/'+route
                unless pagenumber == 0
                    start_page = (pagenumber*Gemchan::ChanController::number_per_page-1)*pagenumber
                    end_page = start_page+Gemchan::ChanController::number_per_page
                else
                    startpage = 0
                    end_page = Gemchan::ChanController::number_per_page
                end
                @board_data, page_data = Gemchan::ChanController::board_page_data('/'+route)
                @board_id = @board_data[:id]
                @action_url = "/create_op"
                @is_thread = false
                if page_data.size > end_page
                    @more = true
                end
                squashme = page_data.keys[start_page..end_page]
                unless squashme.nil?
                    @page_data = page_data.slice(*squashme.flatten)
                    @route = '/'+route
                    erb :board
                else
                    erb :page_not_found
                end
            else
                erb :page_not_found
            end
        end

        get '/*/*/?' do |route, op|
            if Gemchan::ChanController::boards_dict.has_key? '/'+route
                if Op.exists?(post_id: op)
                    @op_id = op
                    @board_id, @posts = Gemchan::ChanController::thread_page_data(@op_id, '/'+route)
                    @is_thread = true
                    @action_url = "/reply"
                    erb :thread
                else 
                    erb :page_not_found
                end
            end
        end

        get '/*/?' do |route|
            redirect "/#{route}/page/0"
        end

    end
end
