require 'active_record'
module Gemchan
    
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '/Users/david/chandir/gemchan.db')
    class Board < ActiveRecord::Base
        validates_presence_of :name
        validates_presence_of :upath
        validates :upath, uniqueness: true
        has_many :posts
    end
    
    class Post < ActiveRecord::Base
        validates_presence_of :content
        belongs_to :board
        has_many :replys
    end
    
    class Reply < ActiveRecord::Base
        validates_presence_of :content
        belongs_to :post
    end

end