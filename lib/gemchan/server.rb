require 'sinatra'
module Gemchan
    class Server < Sinatra::Base
        get '/' do
            Gemchan::Board.find_each do |board|
                board.posts.each do |post|
                    "#{post[:content]}"
                end
            end
        end
    end
end
