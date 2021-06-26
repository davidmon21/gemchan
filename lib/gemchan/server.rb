require 'sinatra'
require 'fileutils'
module Gemchan
    class InfoCache
        @@boards = {}
        puts "here"
        def self.init
            Board.find_each do |board|
                @@boards[board[:upath]] = board[:id]
            end
        end
        def self.boards_dict
            return @@boards
        end
        def self.update_boards_dict
            Board.find_each do |board|
                @@boards[board[:upath]] = board[:id]
            end
        end
    end

    class Server < Sinatra::Base
        configure do
            InfoCache::init()
        end

        enable :sessions
        set :root, "/Users/david/chandir"
        post '/createboard' do
            unless InfoCache::boards_dict.has_key? params[:upath] 
                Board.create(upath: params[:upath], name: params[:name], description: params[:description])
                InfoCache::update_boards_dict
            else 
                puts "board exists"
            end
        end
        post '/reply' do
            board = Board.find(params[:board])
            op = params[:op]
            tempfile = params[:file][:tempfile] 
            filename = params[:file][:filename] 
            FileUtils.cp(tempfile.path, "/Users/david/chandir/public/uploads/#{filename}")
            board.posts.create(content: params[:content], op_id: params[:op], media: "/public/uploads/#{filename}")
            board.posts.find(params[:op]).touch
            
        end

        post '/create_op' do
            board = Board.find(params[:board])
            tempfile = params[:file][:tempfile] 
            filename = params[:file][:filename] 
            FileUtils.cp(tempfile.path, "/Users/david/chandir/public/uploads/#{filename}")
            op = board.posts.create(content: params[:content],media: "/public/uploads/#{filename}")
            op_post = board.ops.create(post_id: op[:id])
            op.op_id = op.id
            op.save
        end
        get '/' do
            erb :index 
        end
        get '/manage' do
            erb :admin
        end
        get '/:board' do
            @board = Board.find(InfoCache::boards_dict[params[:board]])
            erb :board
        end
        get '/:board/:pid' do 
            @op = Post.find(params[:pid])
            @posts = Post.where "op_id = #{params[:pid]}"
            @posts = @posts.sort_by(&:created_at)
            #.reverse
            erb :thread
        end
        #no
    end
end
