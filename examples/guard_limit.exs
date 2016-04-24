# mix run -S iex --no-halt examples/ip_limit.exs
# curl -i http://localhost:4000/
defmodule GuardLimit do
  defmodule Guard do
    use Ralitobu.Plug.Guard

    def call(conn, _opts) do
      :random.seed(:erlang.timestamp)
      bucket = "guard-bucket-#{:random.uniform(3)}"
      conn
      |> put_resp_header("ratelimit-guard", "GuardLimit.Guard")
      |> put_resp_header("ratelimit-bucket", bucket)
      |> put_state([bucket: bucket, limit: 5, lifetime: 30_000])
    end
  end

  defmodule Router do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug Ralitobu.Plug, guard: GuardLimit.Guard
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

GuardLimit.run
