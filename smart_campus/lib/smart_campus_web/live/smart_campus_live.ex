defmodule SmartCampusWeb.SmartCampusLive do
  use SmartCampusWeb, :live_view
  import Ecto.Query
  alias SmartCampus.Repo
  alias SmartCampus.Measurement

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)
    socket = assign(socket, temperature: 0, humidity: 0, noise: 0, light: 0, motion: "Active", co2: 0, datetime: "17 Oct 2023 12:00:00")
    # update_measurement(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Sensor Outputs:</h1>
    <div id="outputs">
      <p><b>Temperature:</b> <%= @temperature %>°C</p>
      <p><b>Humidity:</b> <%= @humidity %>g/m³</p>
      <p><b>Noise:</b> <%= @noise %> dB</p>
      <p><b>Light:</b> <%= @light %> lumens</p>
      <p><b>Motion:</b> <%= @motion %></p>
      <p><b>CO²:</b> <%= @co2 %>ppm</p>
      <p><b>Timestamp:</b> <%= @datetime %></p>
    </div>
    """
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    measurement = Repo.one(from m in Measurement, order_by: [desc: m.inserted_at], limit: 1)
      |> Map.from_struct
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
    measurement = Map.put(measurement, :datetime, measurement.inserted_at)
    measurement = Map.drop(measurement, [:__meta__, :updated_at, :id, :inserted_at])

    {:noreply, assign(socket, measurement)}
  end
end
