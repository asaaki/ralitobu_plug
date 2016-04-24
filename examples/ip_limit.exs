# mix run -S iex --no-halt examples/ip_limit.exs
# curl -i http://localhost:4000/
defmodule IPLimit do
  defmodule Router do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug Ralitobu.Plug, on_ip: true, limit: 3, lifetime: 10_000
    plug :match
    plug :dispatch

    match _ do
      send_resp(conn, 200, "hello world\n")
    end
  end

  def run do
    Application.ensure_started(:logger)
    Application.ensure_started(:ralitobu)
    Plug.Adapters.Cowboy.http(Router, [], port: 4000)
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown(Router)
  end
end

IPLimit.run
