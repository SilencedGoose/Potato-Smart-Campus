
# this is a copy of the same file in the webserver
defmodule Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "measurements" do
    field :co2, :integer
    field :humidity, :float
    field :light, :float
    field :motion, :boolean, default: false
    field :noise, :integer
    field :temperature, :float

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:temperature, :humidity, :noise, :light, :motion, :co2])
    # |> validate_required([:temperature, :humidity, :noise, :light, :motion, :co2])
    |> validate_required([])
  end
end
