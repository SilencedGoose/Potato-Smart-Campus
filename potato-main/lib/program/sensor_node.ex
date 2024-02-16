defmodule SensorNode do
  require Logger
  use Creek
  use Potato.DSL
  alias Creek.Source.Subject, as: Subject
  alias Creek.Source, as: Source

  def init() do
    # Our node descriptor.
    nd = %{
      hardware: :raspberry_pi,
      type: :sensor_node,
      name: "sensor_node",
      uuid: ?a..?z |> Enum.shuffle() |> to_string
    }

    Potato.Network.Meta.set_local_nd(nd)
  end

  def run() do
    init()
  end

  def read_measurement() do
    {:ok, i2c_pid} = ElixirALE.I2C.start_link("i2c-1", 0x45)
    [{:ok, temp}, {:ok, humidity}] = SHT3x.single_shot_result(i2c_pid, :high, true)
    {:ok, sensor} = BH1750.start_link
    {:ok, lux} = BH1750.measure(sensor)
    Process.sleep(5000)
    %{temperature: temp, humidity: humidity, light: lux}
  end

end