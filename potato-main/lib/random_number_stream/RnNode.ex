defmodule RnNode do
    alias Potato.Network.Observables, as: Net
    require Logger
    use Potato.DSL
  
    def init() do
      # Our node descriptor.
      nd = %{
        hardware: :raspberrypi,
        type: :node,
        name: "node",
        uuid: ?a..?z |> Enum.shuffle() |> to_string
      }
  
      Potato.Network.Meta.set_local_nd(nd)
    end
  
    def run() do
      init()
      
      nil
    end
  end
  