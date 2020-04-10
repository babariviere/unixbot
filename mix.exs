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
        plt_add_deps: :transitive
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Unixbot, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.6"},
      {:crontab, "~> 1.1"},

      # Dev dependencies
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["credo", "dialyzer"],
      audit: ["hex.audit", "hex.outdated"]
    ]
  end
end
