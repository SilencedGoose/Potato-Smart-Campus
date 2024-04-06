defmodule SensorNode do
  require Logger
  use Creek
  use Potato.DSL
  alias Creek.Source.Subject, as: Subject
  alias Creek.Source, as: Source

  def init() do
    # Our node descriptor.
    nd = %{                                                                               #MN           
      hardware: :raspberry_pi,                                                            #MN
      type: :sensor_node,                                                                 #MN
      name: "sensor_node",                                                                #MN
      uuid: ?a..?z |> Enum.shuffle() |> to_string                                         #MN
    }                                                                                     #MN

    Potato.Network.Meta.set_local_nd(nd)                                                  #MN
  end

  def run() do
    init()                                                                                #SN

    Process.sleep(10000)
    exit :kaboom
  end

  def read_measurement() do
    m = %{temperature: nil, humidity: nil, light: nil, noise: nil, motion: nil, co2: nil, sensor_failure: false, node_id: to_string(node)}                                                             # 

    # temperature/humidity sensor
    m = case ElixirALE.I2C.start_link("i2c-1", 0x45) do                                   #
      {:ok, i2c_pid} ->                                                                   #
        case SHT3x.single_shot_result(i2c_pid, :high, true) do                            #
        [{:ok, temp}, {:ok, humidity}] -> Map.merge(m, %{humidity: Float.ceil(humidity, 1), temperature: Float.ceil(temp, 1)})                                                                       #
        _ -> Map.put(m, :sensor_failure, true)                                            #
      end
      _ -> Map.put(m, :sensor_failure, true)                                              #
    end
    # light sensor
    m = case BH1750.start_link do
      {:ok, sensor} -> 
        case BH1750.measure(sensor) do
          {:ok, light} -> Map.put(m, :light, Float.ceil(light, 1))
          _ -> Map.put(m, :sensor_failure, true)
        end
      _ -> Map.put(m, :sensor_failure, true)
    end
    # noise sensor
    m = case Circuits.SPI.open("spidev0.0", speed_hz: 1200000) do
      {:ok, ref} ->
        case Circuits.SPI.transfer(ref, <<0x80, 0x00>>) do
          {:ok, <<_::size(6), noise::size(10)>>} -> Map.put(m, :noise, noise)
          _ -> Map.put(m, :sensor_failure, true)
        end
      _ -> Map.put(m, :sensor_failure, true)
    end
    # motion sensor
    m = case Circuits.GPIO.open("GPIO17", :input) do
      {:ok, gpio} ->
        case Circuits.GPIO.read(gpio) do
          {_, _} -> Map.put(m, :sensor_failure, true)
          motion -> Circuits.GPIO.close(gpio)
            Map.put(m, :motion, (fn v -> if v == 0, do: false, else: true end).(motion))
        end
        
      _ -> Map.put(m, :sensor_failure, true)
    end
    # co2 sensor
    m = case Circuits.I2C.open("i2c-1") do
      {:ok, ref} ->
        case Circuits.I2C.read(ref, 0x5a, 11) do
          {_, _} -> Map.put(m, :sensor_failure, true)
          co2 -> Map.put(m, :co2, co2)
        end
      _ -> Map.put(m, :sensor_failure, true)
    end

    Process.sleep(5000)                                                                 #SN
    m
  end

end