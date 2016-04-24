# mix run -S iex --no-halt examples/params_limit.exs
# curl -i http://localhost:4000/ -XPOST -d 'access_token=foobar'
# curl -i 'http://localhost:4000/?access_token=foobar'
defmodule ParamsLimit do
  defmodule Router do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug Plug.Parsers, parsers: [:urlencoded, :multipart] # parses *params
    plug Ralitobu.Plug, on_param: "access_token", limit: 3, lifetime: 10_000
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

ParamsLimit.run
