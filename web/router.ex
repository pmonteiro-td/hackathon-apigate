defmodule Apigate.Router do
  use Apigate.Web, :router

#  pipeline :browser do
#    plug :accepts, ["html"]
#    plug :fetch_session
#    plug :fetch_flash
#    plug :protect_from_forgery
#    plug :put_secure_browser_headers
#  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/contacts/" do
    pipe_through :api

    forward "/", Apigate.Plug.Proxy, [
        scope:   "/contacts/",
        to:      "http://td-s-new-contacts-api.herokuapp.com",
        headers: [{"API-KEY", "td123456"}],
      ]
  end

#  scope "/", Apigate do
#    pipe_through :browser # Use the default browser stack
#
#    get "/", PageController, :index
#  end

  # Other scopes may use custom stacks.
  # scope "/api", Apigate do
  #   pipe_through :api
  # end
end
