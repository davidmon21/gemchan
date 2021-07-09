install_path = Dir.pwd
STDOUT.print "install path?(#{Dir.pwd}) " STDOUT.flush
possible_path = STDIN.gets.chomp
  
unless possible_path == ""
  install_path = possible_path
end

new_config = YAML::Store.new File.join(install_path,'config.yaml')
new_config[:adapter] = "sqlite3"
new_config[:db] = "gemchan.db"

STDOUT.print "threads per board page?[10] " STDOUT.flush

per_page = STDIN.gets.chomp.lstrip
if per_page == ""
    per_page = 10
end
new_config[:per_page] = per_page

STDOUT.print "max thread size?[300] " STDOUT.flush
thread_size = STDIN.gets.chomp.lstrip
if thread_size == ""
    thread_size = 300
end
new_config[:thread_size] = thread_size

STDOUT.print "max threads per board?[100] " STDOUT.flush
board_size = STDIN.gets.chomp.lstrip
if board_size == ""
    board_size = 100
end
new_config[:board_size] = board_size

%x{ sqlite3 #{dbname} <<EOF

#{File.read(install_path,'schema.sql')}

EOF
}

