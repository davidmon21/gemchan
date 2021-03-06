require "active_record"
require "securerandom"
require "bcrypt"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "gemchan.db")

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

class Newspost < ActiveRecord::Base
  validates_presence_of :content
end

class Report < ActiveRecord::Base
  validates_presence_of :reported_post
end
