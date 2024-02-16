defmodule Potato.MixProject do
  use Mix.Project

  def project do
    [
      app: :potato,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Potato.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:observables, git: "https://github.com/m1dnight/observables", branch: "master"}
      {:creek, path: "../creek"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:sht3x, "~> 0.1.0"},
      {:bh1750, "~> 0.2"},
      {:circuits_spi, "~> 2.0"},
      {:circuits_gpio, "~> 2.0"}
      # {:plug_cowboy, "~> 2.5"},
      # {:jason, "~> 1.0"},
      # {:phoenix, "~> 1.6.16"},
      # {:phoenix_live_view, "~> 0.17.10"}
    ]
  end
end
