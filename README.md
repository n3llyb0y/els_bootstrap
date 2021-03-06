# ElsBootstrap

Does your code sometimes feel a bit hacked in order to work around ELS authentication during development and testing?

Does pulling out the REMOTE_USER and RPA_USERNAME leave you with a slightly metallic taste at the back of your mouth?

Do you find yourself running multiple queries to pull the identity of the person using your site?

If you answer yes to any of the above then the Els Bootsrap might be your cup of tea.

## What it does

The Els Bootstrap is a Rails engine providing some methods, routes and views to help your product work in the world of ELS authentication - whether you are using a bonafide ELS agent (behind Apache for example) or have rolled your own Web Server.

It does this by interacting with the OpenAM HTTP API in order to provide credential authentication and SSO token identity lookup.

When in ELS Identity mode, the Els Bootstrap will attempt to create a user identity from a known cookie SSO token. If no cookie is found (because you are developing, for example) then the user is directed to a built-in logon page where valid credentials can be supplied and validated against ELS - just as they would in production! However, if you want to put any ol' username in to test your app then you can override the auth and create a mock user.

## How it does it

When you include the gem, your Rails project will get 2 helper methods that you can use in any of your controllers (probably as before_filter methods).

1. *cdid*. When used it will attempt to retrieve the REMOTE_USER or RPA_USERNAME header value. This is a very typical operation. The value is stashed in session[:cdid] and provides a *@cdid* instance variable for all controllers. Boring :p

2. *els_identity*. When used your application will do whatever it can to generate a user identity based on the value of the ELS SSO token. The token can be retrieved from the browser or generated anew via a custom login process. This stashes the SSO token in session[:els_token] and results in an *@els_identity* instance variable accessible across all controllers. Mega :D

_els_identity_ will not only result in a user cdid, but also their name, email address, employee number, AD Group membership (baked in roles!), account status and a few other tidbits. So unless you are after the entire HR Record, this is all you'll need for user identity in your app :)


## How to use it

*add the gem to your Gemfile
 gem 'els_bootstrap', "~>0.0.3.2"

*tell the plugin about the openAM instance and the cookies it uses. In config/els_token.yml do something like this:
  development:
    uri: https://elsdev-sso.my.domain/opensso/identity
    cookie: ssoDevCookie
  production:
    uri: https://els-sso.my.domain/opensso/identity
    cookie: sooProdCookie

*call els_identity in your controller. Example:
 class ApplicationController < ActionController::Base
  before_filter :els_identity
 end

If you do need to pull up an additional model, you might want to chain a before_filter. For example:
 class ApplicationController < ActionController::Base
  before_filter :els_identity,:my_model

  def my_model
    if @els_identity
      @my_model ||= MyModel.find_by_name(@els_identity.name)
    end
 end

## TODO

It would be nice to marshal an, optional, internal model automatically.
Generator for the els_token.yml config

## Contributing
Yes please.
fork, hack, send pull request :)
