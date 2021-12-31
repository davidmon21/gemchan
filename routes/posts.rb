class GemChan < Sinatra::Application
  post "/reply" do
    ChanController::create_post(params)
    redirect back
  end

  post "/report_post" do
    ChanController::report_post(params)
    redirect back
  end

  post "/create_news" do
    env["warden"].authenticate!
    ChanController::create_news(params)
    redirect back
  end

  post "/create_op" do
    puts params.inspect
    ChanController::create_post(params, is_op = true)
    redirect back
  end

  post "/delete" do
    ChanController::delete_post(params)
    redirect back
  end
end
