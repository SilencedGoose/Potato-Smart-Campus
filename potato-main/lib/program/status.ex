defmodule Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statuses" do
    field :node_id, :string
    field :sensor_node_hardware_status, :string
    field :sensor_node_software_status, :string
    field :sensor_status, :string

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:node_id, :sensor_status, :sensor_node_hardware_status, :sensor_node_software_status])
    |> validate_required([:node_id, :sensor_status, :sensor_node_hardware_status, :sensor_node_software_status])
  end
end
