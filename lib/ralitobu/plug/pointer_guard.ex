defmodule Ralitobu.Plug.PointerGuard do
  @moduledoc """
  The pointer guard is used internally for all standard `on_*` setups
  """

  use Ralitobu.Plug.Guard

  @default_global_bucket :ralitobu_plug_global_bucket
  # internal defaults: 10 req/s
  @default_limit 10
  @default_lifetime 1_000

  @doc """
  ## Pointer examples

      # property of conn itself:
      plug Ralitobu.Plug, on_conn: :remote_ip, limit: 3, lifetime: 10_000

      # a header field:
      plug Ralitobu.Plug, on_conn: [:req_headers, "access-token"]

      # params:
      plug Plug.Parsers, parsers: [:urlencoded, :multipart] # parses *params
      plug Ralitobu.Plug, on_conn: [:params, "access_token"]
      plug Ralitobu.Plug, on_conn: [:query_params, "access_token"]
      plug Ralitobu.Plug, on_conn: [:body_params, "access_token"]
  """
  def call(conn, pointer, opts) do
    put_state(conn, [
      bucket: bucket(conn, pointer, opts),
      limit: get(opts, :limit),
      lifetime: get(opts, :lifetime)
    ])
  end

  defp bucket(conn, pointer, opts),
    do: peek(conn, pointer) || get(opts, :bucket)

  defp get(opts, key),
    do: Dict.get(opts, key, defaults[key])

  defp defaults do
    Application.get_env(:ralitobu_plug, Ralitobu.Plug.PointerGuard, [
      bucket: @default_global_bucket,
      limit: @default_limit,
      lifetime: @default_lifetime
    ])
  end
end
