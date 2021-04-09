defmodule Vaxer.MixProject do
  use Mix.Project

  def project do
    [
      app: :vaxer,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      default_release: :vaxer,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vaxer.Application, []}
    ]
  end

  def releases() do
    [
      vaxer: [
        applications: [ex_unit: :permanent]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:wallaby, "~> 0.28.0"},
      {:ex_twilio, "~> 0.9.0"},
      {:nimble_csv, "~> 1.0"}
    ]
  end
end
