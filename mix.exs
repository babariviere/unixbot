defmodule Unixbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :unixbot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],

      # Docs
      name: "Unixbot",
      source_url: "https://github.com/babariviere/unixbot",
      docs: [
        main: "Unixbot",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Unixbot.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.6"},
      {:crontab, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},

      # Dev dependencies
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["dialyzer", "credo", "inch"],
      audit: ["hex.audit", "hex.outdated"]
    ]
  end
end
