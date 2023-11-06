defmodule SmartCampus.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :temperature, :float
      add :humidity, :float
      add :noise, :integer
      add :light, :float
      add :motion, :boolean, default: false, null: false
      add :co2, :integer

      timestamps()
    end
  end
end
