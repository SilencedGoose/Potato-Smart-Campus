defmodule Server do
  alias Potato.Network.Observables, as: Net
  require Logger
  use Creek
  use Potato.DSL
  alias Creek.Source.Subject, as: Subject
  alias Creek.Source, as: Source

  def init() do
    # Our node descriptor.
    nd = %{                                                                                                 #MN
      hardware: :computer,                                                                                  #MN
      type: :server,                                                                                        #MN
      name: "server",                                                                                       #MN
      uuid: ?a..?z |> Enum.shuffle() |> to_string                                                           #MN
    }                                                                                                       #MN

    Potato.Network.Meta.set_local_nd(nd)                                                                    #MN
  end

  defdag read_measurement(src, snk) do
    src                                                                                                     #CO
    ~> map(fn _ -> SensorNode.read_measurement() end)                                                       #SN
  ~> snk                                                                                                    #CO
  end

  defdag stream_measurements(src, snk, measurement_sink) do
    src                                                                                                     #CO
    ~> filter(fn event ->                                                                                   #CO
      Kernel.match?({:join, _}, event)                                                                      #CO
    end)                                                                                                    #CO
    ~> map(fn {:join, device} ->                                                                            #CO
      IO.inspect device, label: "device"                                                                    #CO
        p =                                                                                                 #CO
          program do                                                                                        #CO
          deploy(read_measurement, src: Creek.Source.range(1, :inifinity, 0, 1000), snk: measurement_sink)  #CO
          end                                                                                               #CO

        Subject.next(device.deploy, p)                                                                      #CO
    end)                                                                                                    #CO
    ~> snk                                                                                                  #CO
  end

  defdag upload_measurement(src, snk) do
    src                                                                                                     #CO
    ~> map(fn v -> Repo.insert(%Measurement{temperature: v.temperature, humidity: v.humidity, light: v.light, motion: v.motion, noise: v.noise, co2: v.co2}) end)                                                               #DI
    ~> snk                                                                                                  #CO
  end

  def run() do
    init()                                                                                                  #CO
    kill_switch = Creek.Sink.ignore(nil)                                                                    #CO
    measurements = Creek.Source.gatherer()                                                                  #CO
    deploy(stream_measurements, src: Net.network(), snk: kill_switch, measurement_sink: measurements)       #CO
    deploy(upload_measurement, src: measurements, snk: kill_switch)                                         #CO
    nil                                                                                                     #CO
  end
end