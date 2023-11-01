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

  defdag stream_temp(src, snk) do
    src
    ~> map(fn _ -> SensorNode.read_temperature() end)
    ~> snk
  end

  defdag stream_temperatures(src, snk, temp_sink) do
    src
    ~> filter(fn event ->
      Kernel.match?({:join, _}, event)
    end)
    ~> map(fn {:join, device} ->
      IO.inspect device, label: "device"
        p =
          program do
          deploy(stream_temp, src: Creek.Source.range(1, :inifinity, 0, 1000), snk: temp_sink)
          end

        Subject.next(device.deploy, p)
    end)
    ~> snk
  end

  defdag print_temperature(src, snk) do
    src
    ~> average()
    ~> debug
    ~> snk
  end

  def run() do
    init()
    kill_switch = Creek.Source.gatherer()
    temps = Creek.Source.gatherer()
    deploy(stream_temperatures, src: Net.network(), snk: kill_switch, temp_sink: temps)
    deploy(print_temperature, src: temps, snk: kill_switch)
    nil
  end
end
