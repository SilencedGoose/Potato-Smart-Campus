defmodule SmartCampus.Repo do
  use Ecto.Repo,
    otp_app: :smart_campus,
    adapter: Ecto.Adapters.Postgres
end
