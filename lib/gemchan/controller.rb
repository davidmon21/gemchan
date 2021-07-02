module Gemchan
    class ChanController
        @@boards = {}
        @@root = "/var/www"
        @@config_path = File.join(Dir.home, '.config', 'gemchan', 'config.yaml')
        @@configurations = Object
        @@allowed_ftypes = ['png','jpeg','gif','webp']

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

            post = board.posts.create(name: params[:name], subject: params[:subject], content: params[:content], media: filepath)
            
            unless is_op
                op_post = board.ops.where("post_id = #{params[:op]}")
                op_post.reload
                op_post.save
                post.op_id = params[:op]
            else
                op_post = board.ops.create(post_id: post[:id])
                post.op_id = post.id
            end
            post.save
        end

        def self._handle_file(tempfile, filename)
            mtype = MimeMagic.by_magic(File.open(tempfile.path))
            dirp = File.join( @@root, "public", "uploads")
            unless @@allowed_ftypes.include? mtype.subtype
                return nil
            end
            md5t = Digest::MD5.file(tempfile.path).hexdigest
            newname = File.join(dirp, "#{md5t}.#{mtype.subtype}")
            thumbname = File.join(dirp, "#{md5t}.thumb.#{mtype.subtype}")
            servename = "/uploads/#{md5t}.#{mtype.subtype}"
            if mtype.mediatype == 'image'
                image = Magick::Image.read(tempfile.path).first
                image.thumbnail(image.columns*(300.0/image.columns), image.rows*(300.0/image.columns)).write(thumbname)
            end
            FileUtils.cp(tempfile.path, newname)

            return servename
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
            self.init
        end

        def self.board_page_data(route)
            page_data = {}
            board = Board.find(@@boards[route])
            page_data[:bid] = board.id
            ops = board.ops.sort_by(&:updated_at).reverse
            for op in ops
                page_data[op.post_id] = board.posts.where("op_id = #{op.post_id}").last(4)
            end
            return page_data
        end

        def self.thread_page_data(thread, route)
            bid = Gemchan::ChanController::boards_dict[route]
            posts = Post.where("op_id = #{thread}").sort_by(&:created_at)
            return bid, posts
        end

    end
end