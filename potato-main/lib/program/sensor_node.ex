defmodule SensorNode do
  require Logger
  use Creek
  use Potato.DSL
  alias Creek.Source.Subject, as: Subject
  alias Creek.Source, as: Source

  def init() do
    # Our node descriptor.
    nd = %{                                                                             //MN           
      hardware: :raspberry_pi,                                                          //MN
      type: :sensor_node,                                                               //MN
      name: "sensor_node",                                                              //MN
      uuid: ?a..?z |> Enum.shuffle() |> to_string                                       //MN
    }                                                                                   //MN

    Potato.Network.Meta.set_local_nd(nd)                                                //MN
  end

  def run() do
    init()                                                                              //SN
  end

  def read_measurement() do
    {:ok, i2c_pid} = ElixirALE.I2C.start_link("i2c-1", 0x45)                            //SI
    [{:ok, temp}, {:ok, humidity}] = SHT3x.single_shot_result(i2c_pid, :high, true)     //SI
    {:ok, sensor} = BH1750.start_link                                                   //SI
    {:ok, light} = BH1750.measure(sensor)                                               //SI
    {:ok, ref} = Circuits.SPI.open("spidev0.0", speed_hz: 1200000)                      //SI
    {:ok, <<_::size(6), noise::size(10)>>} = Circuits.SPI.transfer(ref, <<0x80, 0x00>>) //SI
    {:ok, gpio} = Circuits.GPIO.open("GPIO17", :input)                                  //SI
    motion = Circuits.GPIO.read(gpio)                                                   //SI
    Circuits.GPIO.close(gpio)                                                           //SI
    {:ok, ref} = Circuits.I2C.open("i2c-1")                                             //SI
    co2 = Circuits.I2C.read(ref, 0x5a, 11)                                              //SI
    Process.sleep(5000)                                                                 //SN
    %{temperature: Float.ceil(temp, 1), humidity: Float.ceil(humidity, 1), light: Float.ceil(light, 1), noise: noise, motion: (fn v -> if v == 0, do: false, else: true end).(motion), co2: co2}          //CO
  end

end