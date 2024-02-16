defmodule Server do
  alias Potato.Network.Observables, as: Net
  require Logger
  use Creek
  use Potato.DSL
  alias Creek.Source.Subject, as: Subject
  alias Creek.Source, as: Source

  def init() do
    # Our node descriptor.
    nd = %{
      hardware: :computer,
      type: :server,
      name: "server",
      uuid: ?a..?z |> Enum.shuffle() |> to_string
    }

    Potato.Network.Meta.set_local_nd(nd)
  end

  defdag read_measurement(src, snk) do
    src
    ~> map(fn _ -> SensorNode.read_measurement() end)
    ~> snk
  end

  defdag stream_measurements(src, snk, measurement_sink) do
    src
    ~> filter(fn event ->
      Kernel.match?({:join, _}, event)
    end)
    ~> map(fn {:join, device} ->
      IO.inspect device, label: "device"
        p =
          program do
          deploy(read_measurement, src: Creek.Source.range(1, :inifinity, 0, 1000), snk: measurement_sink)
          end

        Subject.next(device.deploy, p)
    end)
    ~> snk
  end

  defdag upload_measurement(src, snk) do
    src
    ~> map(fn v -> Repo.insert(%Measurement{temperature: v.temperature, humidity: v.humidity, light: v.light, motion: v.motion, noise: v.noise}) end)
    ~> snk
  end

  def run() do
    init()
    kill_switch = Creek.Sink.ignore(nil)
    measurements = Creek.Source.gatherer()
    deploy(stream_measurements, src: Net.network(), snk: kill_switch, measurement_sink: measurements)
    deploy(upload_measurement, src: measurements, snk: kill_switch)
    nil
  end
end