class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :heads
  
  def heads
    logger.debug(request.inspect)
    logger.debug("guery: " + request.env["QUERY_STRING"])
    logger.debug("red: " + session[:redirect_to])
  end
end
