module Gemchan
    class ChanController
        @@root = "/var/www"
        def self.init(root_path)
            @@root = root_path
        end
        def self.handle_file(tempfile, filename)
            FileUtils.cp(tempfile.path, File.join( @root, "public", "uploads", filename))
            #gonna need more here
            return File.join("uploads",filename)
        end
        def self.root
            return @@root
        end
    end
end