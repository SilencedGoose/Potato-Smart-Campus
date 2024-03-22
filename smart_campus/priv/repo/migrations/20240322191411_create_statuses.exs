defmodule SmartCampus.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :node_id, :string
      add :sensor_status, :string
      add :sensor_node_hardware_status, :string
      add :sensor_node_software_status, :string

      timestamps()
    end
  end
end
