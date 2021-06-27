module Gemchan
    class ChanController
        @root = "/Users/david/chandir"
        def handle_file(tempfile, filename)
            FileUtils.cp(tempfile.path, File.join( @root, "public", "uploads", filename))
            #gonna need more here
            return File.join("uploads",filename)
        end
    end
end