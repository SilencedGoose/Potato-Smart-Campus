defmodule SmartCampusWeb.SmartCampusLive do
  use SmartCampusWeb, :live_view
  import Ecto.Query
  alias SmartCampus.Repo
  alias SmartCampus.Measurement

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update_measurement, 1000)            //WI
    # SmartCampusWeb.Endpoint.subscribe("new_measurement")
    IO.inspect(self())                                                                          //WI
    {:ok, assign(socket, temperature: 0, humidity: 0, noise: 0, light: 0, motion: "Active", co2: 0, datetime: "17 Oct 2023 12:00:00")}                                                                            //WI
  end

  def render(assigns) do                                                                        //WI "lines: 11"
    ~H"""
    <div id="outputs">
      <p><b>Temperature:</b> <%= @temperature %></p>
      <p><b>Humidity:</b> <%= @humidity %></p>
      <p><b>Noise:</b> <%= @noise %></p>
      <p><b>Light:</b> <%= @light %></p>
      <p><b>Motion:</b> <%= @motion %></p>
      <p><b>CO²:</b> <%= @co2 %></p>
      <p><b>Timestamp:</b> <%= @datetime %></p>
    </div>
    """
  end

  def handle_info(:update_measurement, socket) do
    Process.send_after(self(), :update_measurement, 5000)                                       //WI
    measurement = Repo.one(from m in Measurement, order_by: [desc: m.inserted_at], limit: 1)    //DI
      |> Map.from_struct                                                                        //WI
      |> Enum.filter(fn {_, v} -> v != nil end)                                                 //WI
      |> Enum.into(%{})                                                                         //WI
    measurement = Map.put(measurement, :datetime, measurement.inserted_at)                      //WI
    measurement = Map.drop(measurement, [:__meta__, :updated_at, :id, :inserted_at])            //WI

    {:noreply, assign(socket, measurement)}                                                     //WI
  end
end
