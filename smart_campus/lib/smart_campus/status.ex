defmodule SmartCampus.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statuses" do
    field :co2, :boolean, default: false
    field :humidity, :boolean, default: false
    field :light, :boolean, default: false
    field :motion, :boolean, default: false
    field :node_id, :string
    field :noise, :boolean, default: false
    field :pi, :boolean, default: false
    field :temperature, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:pi, :temperature, :humidity, :noise, :light, :motion, :co2, :node_id])
    |> validate_required([:pi, :temperature, :humidity, :noise, :light, :motion, :co2, :node_id])
  end
end
