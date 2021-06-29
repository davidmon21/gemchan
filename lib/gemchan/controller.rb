module Gemchan
    class ChanController
        @@boards = {}
        @@root = "/var/www"
        @@config_path = File.join(Dir.home, '.config', 'gemchan', 'config.yaml')
        @@configurations = Object

        def self.init
            Board.find_each do |board|
                @@boards[board[:upath]] = board[:id]
            end
            @@configurations = YAML.load(File.read(@@config_path))
            @@root = @@configurations[:root]
        end

        def self.configurations
            if @@configurations == Object
                @@configurations = YAML.load(File.read(@@config_path))
            end
            return @@configurations
        end

        def self.create_post(params, is_op=false)
            board = Board.find(params[:board])

            if params[:file] == nil
                filepath = nil
            else
                puts params[:file].inspect()
                filepath = self._handle_file(params[:file][:tempfile],params[:file][:filename])
            end

            post = board.posts.create(content: params[:content], media: filepath)
            
            unless is_op
                board.posts.find(params[:op]).touch
                post.op_id = params[:op]
            else
                op_post = board.ops.create(post_id: post[:id])
                post.op_id = post.id
            end
            post.save
        end

        def self._handle_file(tempfile, filename)
            FileUtils.cp(tempfile.path, File.join( @@root, "public", "uploads", filename))
            return "/uploads/#{filename}"
        end

        def self.boards_dict
            return @@boards
        end

        def self.root
            return @@root
        end

        def self.update_boards_dict
            Board.find_each do |board|
                @@boards[board[:upath]] = board[:id]
            end
        end

        def self.createboard(params)
            unless @@boards.has_key? params[:upath] 
                @@boards[params[:upath]] = Board.create(upath: params[:upath], name: params[:name], description: params[:description]).id
            else 
                puts "board exists"
            end
        end

    end
end