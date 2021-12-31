class GemChan < Sinatra::Application
  get "/auth/login" do
    erb :login
  end

  post "/auth/login" do
    env["warden"].authenticate!

    if session[:return_to].nil?
      redirect "/"
    else
      redirect session[:return_to]
    end
  end

  get "/auth/logout" do
    env["warden"].raw_session.inspect
    env["warden"].logout
    redirect "/"
  end

  post "/auth/unauthenticated" do
    session[:return_to] = env["warden.options"][:attempted_path] if session[:return_to].nil?

    # Set the error and use a fallback if the message is not defined

    redirect "/auth/login"
  end

  ##session and authentication needed for below

  get "/manage" do
    env["warden"].authenticate!
    @is_news = true
    @action_url = "/create_news"
    erb :admin
  end

  get "/manage/:board" do
    env["warden"].authenticate!
    if ChanController::boards_dict.has_key? "/" + params[:board]
      erb :adminboard
    else
      erb :page_not_found
    end
  end

  post "/delete" do
    env["warden"].authenticate!
    ChanController::delete_post(params)
    redirect back
  end

  post "/createboard" do
    env["warden"].authenticate!
    ChanController::createboard(params)
    ChanController::update_boards_dict
    redirect back
  end

  post "/admin_post" do
    env["warden"].authenticate!
    ChanController::create_admin_post(params)
    redirect back
  end
end
