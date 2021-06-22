require 'sinatra'
module Gemchan
    class Server < Sinatra::Base
        enable :sessions
        set :root, "/Users/david/chandir"
        get '/' do
            #Gemchan::Board.find_each do |board|
            #    @posts = board.posts
            #end
            erb :index 
        end
        get '/createboard/:p' do
            Board.create(upath: params[:p], name: 'b', description: 'random')
        end
        get '/:board' do
            @board = Board.find_by_upath(params[:board])
            erb :board
        end
        get '/:board/createpost/:postcontent' do
            board = Board.find_by_upath(params[:board])
            op = board.posts.create(content: params[:postcontent])[:id]
            board.ops.create(post_id: op)
        end
        get '/:board/:pid' do 
            @op = Post.find(params[:pid])
            @posts = Post.where "op_id = #{params[:pid]}"
            erb :thread
        end
        get '/:board/:pid/reply/:content' do
            board = Board.find_by_upath(params[:board])
            board.posts.create(content: params[:content], op_id: params[:pid])
        end
        post '/reply' do
            #broken
            board = Board.find_by_upath(params[:board])
            board.posts.create(content: params[:content], op_id: params[:pid])
        end
    end
end
