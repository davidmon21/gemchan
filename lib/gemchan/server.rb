require 'sinatra'

module Gemchan

    class Server < Sinatra::Base
        configure do
            Gemchan::ChanController::init( )
        end

        enable :sessions
        set :root, ChanController::root

        post '/reply' do
            Gemchan::ChanController::create_post(params)
            redirect back
        end

        post '/create_op' do
            Gemchan::ChanController::create_post(params, is_op=true)
            redirect back
        end

        get '/' do
            erb :index 
        end
        
        Gemchan::ChanController::boards_dict.keys.each do |route|
            get route do
                @board = Board.find(Gemchan::ChanController::boards_dict[route])
                erb :board
            end

            get route+'/:pid' do
                @bid = Gemchan::ChanController::boards_dict[route]
                @op = Post.find(params[:pid])
                @posts = Post.where "op_id = #{params[:pid]}"
                @posts = @posts.sort_by(&:created_at)
                #.reverse
                erb :thread
            end
        end

        ##session and authentication needed for below

        get '/manage' do
            erb :admin
        end

        post '/createboard' do
            Gemchan::ChanController::createboard(params)
            Gemchan::ChanController::update_boards_dict
        end

       
    end
end
