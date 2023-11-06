import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :smart_campus, SmartCampus.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "smart_campus_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smart_campus, SmartCampusWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vzsHSQ6j0y/wtNi46aj7l9vV4l5lPH2unWJdw9p0Mfw8K0DLZjHAFqnxIJq4E39Q",
  server: false

# In test we don't send emails.
config :smart_campus, SmartCampus.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
