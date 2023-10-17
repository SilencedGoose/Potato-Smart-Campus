defmodule SensorLiveviewWeb.ErrorJSONTest do
  use SensorLiveviewWeb.ConnCase, async: true

  test "renders 404" do
    assert SensorLiveviewWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SensorLiveviewWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
