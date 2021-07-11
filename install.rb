require 'yaml/store'
dbtype = "sqlite3"
dbname = "gemchan.db"
allowed_ftypes = ['png','jpeg','gif','webp']
install_path = Dir.pwd
STDOUT.print "install path?(#{Dir.pwd}) " 
STDOUT.flush
possible_path = STDIN.gets.chomp

unless possible_path == ""
  install_path = possible_path
end

STDOUT.print "threads per board page?[10] " 
STDOUT.flush
per_page = STDIN.gets.chomp.lstrip
if per_page == ""
    per_page = 10
end


STDOUT.print "max thread size?[300] " 
STDOUT.flush
thread_size = STDIN.gets.chomp.lstrip
if thread_size == ""
    thread_size = 300
end


STDOUT.print "max threads per board?[100] " 
STDOUT.flush
board_size = STDIN.gets.chomp.lstrip
if board_size == ""
    board_size = 100
end

STDOUT.print "max post size(text length)?[2500] " 
STDOUT.flush
max_post_size = STDIN.gets.chomp.lstrip
if max_post_size == ""
    max_post_size = 2500
end

new_config = YAML::Store.new File.join(install_path,'config.yaml')
new_config.transaction do
    new_config[:adapter] = dbtype
    new_config[:db] = dbname
    new_config[:board_size] = board_size
    new_config[:thread_size] = thread_size
    new_config[:per_page] = per_page
    new_config[:max_post_size] = max_post_size
    new_config[:allowed_ftypes] = allowed_ftypes
    new_config[:about] = "set your about yo"
end


%x{ sqlite3 #{dbname} <<EOF

#{File.read(File.join(install_path,'schema.sql'))}

EOF
}

