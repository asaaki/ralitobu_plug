defmodule Ralitobu.Plug.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @project_url "https://github.com/asaaki/ralitobu_plug"
  @docs_url "http://hexdocs.pm/ralitobu_plug"

  def project do
    [
      app: :ralitobu_plug,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      package: package,
      description: description,
      source_url: @project_url,
      homepage_url: @docs_url,
      docs: &docs/0,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application, do: []

  defp description do
    """
    Elixir Plug for Ralitobu, the Rate Limiter with Token Bucket algorithm
    """
  end

  defp package do
    [
      maintainers: ["Christoph Grabo"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @project_url,
        "Docs" => "#{@docs_url}/#{@version}/"
      },
      files: package_files
    ]
  end

  defp package_files,
    do: ~w(lib mix.exs README.md LICENSE)

  defp docs do
    [
      extras: ["README.md"], main: "readme",
      source_ref: "v#{@version}", source_url: @project_url
    ]
  end

  defp deps do
    [
      {:ralitobu, "~> 0.1"},
      {:plug, "~> 1.1"},

      {:cowboy, "~> 1.0", only: [:dev]},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.11", only: [:docs]},
      {:cmark, "~> 0.6", only: [:docs]},
    ]
  end
end
