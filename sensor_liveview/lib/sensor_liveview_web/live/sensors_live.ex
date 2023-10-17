defmodule SensorLiveviewWeb.SensorsLive do
  use SensorLiveviewWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, temperature: 0, humidity: 0, noise: 0, light: 0, motion: "Active", co2: 0, datetime: "17 Oct 2023 12:00:00")
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

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end
end
