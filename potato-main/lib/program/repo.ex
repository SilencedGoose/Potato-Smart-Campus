# basically a copy of the file in the website
defmodule Repo do
  use Ecto.Repo,
    otp_app: :potato,
    adapter: Ecto.Adapters.Postgres
end
