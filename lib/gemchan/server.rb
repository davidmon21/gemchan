require 'sinatra'
module Gemchan
    class Server < Sinatra::Base
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
            board.ops.create(post_id: [:id])
        end
        get '/:board/:pid' do
            @post = Post.find(params[:pid])[:content]
            #@replies = @post.replys
            erb :thread
        end
        get '/:board/:pid/reply/:content' do
            Board.find_by_path(params[:board]).posts.create(content: params[:content], op_id: params[:pid])
        end
    end
end
