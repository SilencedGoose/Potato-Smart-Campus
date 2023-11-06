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

  def read_temperature() do
    temp = :rand.uniform_real() * 30
    Process.sleep(5000)
    temp
  end

end
