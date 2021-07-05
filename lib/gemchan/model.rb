require 'active_record'
@schema = 
=begin
CREATE TABLE boards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    upath TEXT,
    name TEXT,
    description TEXT
);
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    password_hash BLOB,
    perms INTEGER
);
CREATE TABLE ops (
    post_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject TEXT,
    name TEXT,
    content TEXT,
    media TEXT,
    op_id      INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
=end

module Gemchan
    
    config = Gemchan::ChanController::configurations()
    ActiveRecord::Base.establish_connection(adapter: config[:adapter], database: config[:db])

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
        self.primary_key = :post_id
        validates_presence_of :post_id
        belongs_to :board
    end

    class User < ActiveRecord::Base
        include BCrypt
        validates_presence_of :username
        validates_presence_of :password_hash

        def password
            @password ||= Password.new(password_hash)
        end

        def password=(new_password)
            @password = Password.create(new_password)
            self.password_hash = @password
        end
    end

end