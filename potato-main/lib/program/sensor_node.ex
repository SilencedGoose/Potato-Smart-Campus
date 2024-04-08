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
  end

  def read_measurement() do
    m = %{temperature: nil, humidity: nil, light: nil, noise: nil, motion: nil, co2: nil, sensor_failure: false, node_id: to_string(node)}                                                             #CO

    # temperature/humidity sensor
    m = case ElixirALE.I2C.start_link("i2c-1", 0x45) do                                   #SI
      {:ok, i2c_pid} ->                                                                   #SEN (Sensor Failure)
        case SHT3x.single_shot_result(i2c_pid, :high, true) do                            #SI
        [{:ok, temp}, {:ok, humidity}] -> Map.merge(m, %{humidity: Float.ceil(humidity, 1), temperature: Float.ceil(temp, 1)})                                                                       #SEN
        _ -> Map.put(m, :sensor_failure, true)                                            #SEN
      end
      _ -> Map.put(m, :sensor_failure, true)                                              #SEN
    end
    # light sensor
    m = case BH1750.start_link do                                                         #SI
      {:ok, sensor} ->                                                                    #SEN
        case BH1750.measure(sensor) do                                                    #SI
          {:ok, light} -> Map.put(m, :light, Float.ceil(light, 1))                        #SEN
          _ -> Map.put(m, :sensor_failure, true)                                          #SEN
        end
      _ -> Map.put(m, :sensor_failure, true)                                              #SEN
    end
    # noise sensor
    m = case Circuits.SPI.open("spidev0.0", speed_hz: 1200000) do                         #SI
      {:ok, ref} ->                                                                       #SEN
        case Circuits.SPI.transfer(ref, <<0x80, 0x00>>) do                                #SI
          {:ok, <<_::size(6), noise::size(10)>>} -> Map.put(m, :noise, noise)             #SEN
          _ -> Map.put(m, :sensor_failure, true)                                          #SEN
        end
      _ -> Map.put(m, :sensor_failure, true)                                              #SEN
    end
    # motion sensor
    m = case Circuits.GPIO.open("GPIO17", :input) do                                      #SI
      {:ok, gpio} ->                                                                      #SEN
        case Circuits.GPIO.read(gpio) do                                                  #SI
          {_, _} -> Map.put(m, :sensor_failure, true)                                     #SEN
          motion -> Circuits.GPIO.close(gpio)                                             #SI
            Map.put(m, :motion, (fn v -> if v == 0, do: false, else: true end).(motion))  #SEN
        end
      _ -> Map.put(m, :sensor_failure, true)                                              #SEN
    end
    # co2 sensor
    m = case Circuits.I2C.open("i2c-1") do                                                #SI
      {:ok, ref} ->                                                                       #SEN
        case Circuits.I2C.read(ref, 0x5a, 11) do                                          #SI
          {_, _} -> Map.put(m, :sensor_failure, true)                                     #SEN
          co2 -> Map.put(m, :co2, co2)                                                    #SEN
        end
      _ -> Map.put(m, :sensor_failure, true)                                              #SEN
    end

    Process.sleep(5000)                                                                   #SN
    m                                                                                     #CO
  end

end