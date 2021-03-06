class ElsSessionController < ApplicationController

  include ElsToken
  els_config YAML.load_file("#{Rails.root}/config/els_token.yml")[Rails.env]

  before_filter :els_identity, :only => [:show]

  def show
  end

  # When in dev/qa we may need to provide credentials
  # if ELS has not been setup
  # this will be valid if a known cookie exists
  def new
    @els_identity = get_identity rescue nil
    if @els_identity
      logger.debug("retrieved els identity #{@els_identity.inspect}")
      session[:els_token] = @els_identity.token_id
      Rails.cache.write(session[:els_token], @els_identity, 
        :namespace => "els_identity",
        :expires_in => 1.hour)
      go_back
    end
    logger.debug("unable to retrieve els identity :(")
    # or get some login details  
  end

  # Should not get here during production
  def create
    begin
      if params["override"]
        # just fake the session
        logger.debug("faking session with id #{params["username"]}")
        @els_identity = ElsFaker.new(params["username"])
      else
        logger.debug("attempting to authenticate #{params["username"]}")
        token = authenticate(params["username"],params["password"])
        logger.debug("got token #{token}")
        if token
          @els_identity = get_token_identity(token)
          flash[:notice] = "cannot retrieve identity" unless @els_identity
        else
          flash[:error] = "unable to authenticate"
        end
      end
    rescue Exception => e
      flash[:error] = "Something went wrong #{e.message}"
    end
    if @els_identity
      update_and_return
    else
      render :new
    end
  end

  def destroy
    Rails.cache.delete(session[:els_token], :namespace => "els_identity")
    session[:els_token] = nil
    session[:redirect_to] = nil
    cookies.delete(self.class.els_options['cookie'], :domain => request.env["SERVER_NAME"])
    redirect_to els_session_new_path
  end

  private

  # This app should really be running behind an els processor
  # stashing the els token against the current host should allow
  # for a better dev/qa experience without affecting production
  def stash_cookie
    cookies[self.class.els_options['cookie']] = {
      :value => @els_identity.token_id,
      :domain => request.env["SERVER_NAME"],
      :path => '/',
      :expires => Time.now + 24.hours
    }
  end

  def update_and_return
    stash_cookie
    session[:els_token] = @els_identity.token_id
    logger.debug("got token id #{session[:els_token]}")
    Rails.cache.write(session[:els_token], @els_identity, 
      :namespace => "els_identity",
      :expires_in => 1.hour)
    go_back
  end
  
  def go_back
    if session[:redirect_to].nil? || session[:redirect_to] =~ /els_session\//
      # Do not redirect back to a session action
      redirect_to root_path
    else
      redirect_to session[:redirect_to]
    end
  end
  
  class ElsFaker < ElsToken::ElsIdentity
    attr_accessor :cdid, :token_id
    def initialize(cdid)
      super
      @cdid = cdid
      @token_id = Random.rand
    end 
  end
    

end