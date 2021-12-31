class GemChan < Sinatra::Application
  get "/" do
    @news_posts = Newspost.all.sort_by(&:created_at).reverse
    erb :index
  end

  get "/*/page/*" do |route, pagenumber|
    puts "matched"
    puts route
    puts pagenumber
    pagenumber = pagenumber.to_i
    @pagenumber = pagenumber
    @is_news = false
    if ChanController::boards_dict.has_key? "/" + route
      unless pagenumber == 0
        start_page = (pagenumber * ChanController::number_per_page - 1) * pagenumber
        end_page = start_page + ChanController::number_per_page
      else
        startpage = 0
        end_page = ChanController::number_per_page
      end
      @board_data, page_data = ChanController::board_page_data("/" + route)
      @board_id = @board_data[:id]
      @action_url = "/create_op"
      @is_thread = false
      if page_data.size > end_page
        @more = true
      end
      squashme = page_data.keys[start_page..end_page]
      unless squashme.nil?
        @page_data = page_data.slice(*squashme.flatten)
        @route = "/" + route
        erb :board
      else
        erb :page_not_found
      end
    else
      erb :page_not_found
    end
  end

  get "/*/*/?" do |route, op|
    if ChanController::boards_dict.has_key? "/" + route
      if Op.exists?(post_id: op)
        @op_id = op
        @board_id, @posts = ChanController::thread_page_data(@op_id, "/" + route)
        @is_thread = true
        @action_url = "/reply"
        @is_news = false
        erb :thread
      else
        erb :page_not_found
      end
    end
  end

  get "/*/?" do |route|
    redirect "/#{route}/page/0"
  end
end
