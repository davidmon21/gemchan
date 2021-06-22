require 'active_record'
@schema = 
=begin
CREATE TABLE boards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    upath TEXT,
    name TEXT,
    description TEXT
);
CREATE TABLE ops (
    post_id INTEGER,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT,
    media TEXT,
    op_id      INTEGER,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
=end

module Gemchan
    
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '/Users/david/chandir/gemchan.db')
    
    class Board < ActiveRecord::Base
        validates_presence_of :name
        validates_presence_of :upath
        validates :upath, uniqueness: true
        has_many :posts
        has_many :ops
    end
    
    class Post < ActiveRecord::Base
        validates_presence_of :content
        belongs_to :board
    end
    
    class Op < ActiveRecord::Base
        validates_presence_of :post_id
        belongs_to :board
    end

end