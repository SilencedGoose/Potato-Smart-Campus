defmodule RnServer do
    alias Potato.Network.Observables, as: Net
    require Logger
    use Potato.DSL

    @port 6666
    @multicast {224, 0, 0, 251}
  
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
  
    def run() do
      init()
      {:ok, sender} = :gen_udp.open(0, mode: :binary)
      :ok = :gen_udp.send(sender, @multicast, @port, "hellooo")
      nil
    end
  end
  