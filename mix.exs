defmodule PipetteElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :pipette_elixir,
      version: "0.1.2",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Pipeline-first utilities: control, result, deep paths, parallelism.",
      package: [licenses: ["MIT"], links: %{"GitHub" => "https://github.com/alexzzzs/pipette"}],
      docs: [main: "Pipette", extras: ["README.md", "CHANGELOG.md"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Pipette.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:stream_data, "~> 1.0", only: :test},
      {:benchee, "~> 1.3", only: :dev}
    ]
  end
end
