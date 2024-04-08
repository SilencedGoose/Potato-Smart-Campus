defmodule SmartCampusWeb.SmartCampusLive do
  use SmartCampusWeb, :live_view
  import Ecto.Query
  alias SmartCampus.Repo
  alias SmartCampus.Measurement
  alias SmartCampus.Status

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update_measurement, 1000)            #WI
    # SmartCampusWeb.Endpoint.subscribe("new_measurement")
    IO.inspect(self())                                                                          #WI
    {:ok, assign(socket, temperature: 0, humidity: 0, noise: 0, light: 0, motion: "Active", co2: 0, datetime: "17 Oct 2023 12:00:00", sensor_node_hardware_status: "Working", sensor_node_software_status: "Working", sensor_status: "Working", sensor_data_status: "Data Lost")}                                                #WI
  end

  def render(assigns) do                                                                        #WI "lines: 18"
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
    <div id="statuses">
    <h1>Statuses</h1>
    <p><b>Sensor Node Hardware:</b> <%= @sensor_node_hardware_status %></p>
    <p><b>Sensor Node Software:</b> <%= @sensor_node_software_status %></p>
    <p><b>Attached Sensors:</b> <%= @sensor_status %></p>
    <p><b>Sensor Data:</b> <%= @sensor_data_status %></p>
    </div>
    """
  end

  def handle_info(:update_measurement, socket) do
    Process.send_after(self(), :update_measurement, 5000)                                       #WI
    measurement = Repo.one(from m in Measurement, order_by: [desc: m.inserted_at], limit: 1)    #DI
      |> Map.from_struct                                                                        #WI
      |> Enum.filter(fn {_, v} -> v != nil end)                                                 #WI
      |> Enum.into(%{})                                                                         #WI
    measurement = Map.put(measurement, :datetime, measurement.inserted_at)                      #WI

    # Checks if data was lost (i.e. if the latest record was not uploaded to the database)      
    {_, previous_time} = DateTime.from_naive(measurement.inserted_at, "Etc/UTC")                #LD
    measurement = if DateTime.diff(DateTime.utc_now(), previous_time) > 8 do                    #LD
      Map.put(measurement, :sensor_data_status, "Data Lost")                                    #LD
    else                                                                                        #LD
      Map.put(measurement, :sensor_data_status, "Received")                                     #LD
    end

    measurement = Map.drop(measurement, [:__meta__, :updated_at, :id, :inserted_at])            #WI

    #get statuses to be displayed
    status = Repo.get_by(Status, node_id: "alice@10.42.0.225")                                  #DI
      |> Map.from_struct                                                                        #WI
    status = Map.put(status, :datetime, status.inserted_at)                                     #WI
    status = Map.drop(status, [:__meta__, :updated_at, :id, :inserted_at])                      #WI

    data = Map.merge(measurement, status)                                                       #WI (general FH?)
    {:noreply, assign(socket, data)}                                                            #WI
  end
end
