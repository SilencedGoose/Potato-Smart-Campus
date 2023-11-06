defmodule SmartCampusWeb.PageController do
  use SmartCampusWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
