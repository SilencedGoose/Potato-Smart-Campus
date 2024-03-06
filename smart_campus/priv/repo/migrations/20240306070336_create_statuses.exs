defmodule SmartCampus.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :pi, :boolean, default: false, null: false
      add :temperature, :boolean, default: false, null: false
      add :humidity, :boolean, default: false, null: false
      add :noise, :boolean, default: false, null: false
      add :light, :boolean, default: false, null: false
      add :motion, :boolean, default: false, null: false
      add :co2, :boolean, default: false, null: false

      timestamps()
    end
  end
end
