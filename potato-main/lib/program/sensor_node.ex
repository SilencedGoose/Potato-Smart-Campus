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
    {:ok, light} = BH1750.measure(sensor)
    {:ok, ref} = Circuits.SPI.open("spidev0.0", speed_hz: 1200000)
    {:ok, <<_::size(6), noise::size(10)>>} = Circuits.SPI.transfer(ref, <<0x80, 0x00>>)
    {:ok, gpio} = Circuits.GPIO.open("GPIO17", :input)
    motion = Circuits.GPIO.read(gpio)
    Circuits.GPIO.close(gpio)
    # {:ok, ref} = Circuits.I2C.open("i2c-1")
    # co2 = Circuits.I2C.read(ref, 0x5a, 11)
    Process.sleep(5000)
    %{temperature: Float.ceil(temp, 1), humidity: Float.ceil(humidity, 1), light: Float.ceil(light, 1), noise: noise, motion: (fn v -> if v == 0, do: false, else: true end).(motion)}
  end

end