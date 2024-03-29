defmodule Reservations.MixProject do
  use Mix.Project

  def project do
    [
      app: :reservations,
      version: "0.1.0",
      elixir: "~> 1.14",
      escript: [main_module: Reservations.CLI],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:nimble_parsec, "~> 1.2.3"},
      {:timex, "~> 3.7.9"},
      {:tzdata, "~> 0.1.8", override: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
