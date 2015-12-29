defmodule Apigate.PageController do
  use Apigate.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
