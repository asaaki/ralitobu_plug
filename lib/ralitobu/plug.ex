defmodule Ralitobu.Plug do
  @moduledoc """
  The plug for [Ralitobu](https://github.com/asaaki/ralitobu)
  (Rate Limiter with Token Bucket algorithm)

  ## Examples

      # bucketize on remote IP, allow 10 req/s
      plug Ralitobu.Plug, on_ip: true, limit: 10, lifetime: 1_000

  TODO: Add usage documentation
  """

  import Plug.Conn
  import Ralitobu.Plug.Conn
  alias Ralitobu.Plug.PointerGuard

  @compile {:inline, in_secs: 1}

  def init(options), do: options

  def call(conn, opts) do
    conn
    |> guard(opts)
    |> checkout
    |> put_ratelimit_headers
    |> pass_or_halt
  end

  # on_ip - shortcut for `on_conn: :remote_ip`
  defp guard(conn, [{:on_ip, true} | opts]),
    do: guard(conn, [{:on_conn, :remote_ip} | opts])
  # on_header - shortcut for `on_conn: [:req_headers, key]`
  defp guard(conn, [{:on_header, key} | opts]),
    do: guard(conn, [{:on_conn, [:req_headers, key]} | opts])
  # on_param - shortcut for `on_conn: [:params, key]`
  defp guard(conn, [{:on_param, key} | opts]),
    do: guard(conn, [{:on_conn, [:params, key]} | opts])
  # default pointer guard
  defp guard(conn, [{:on_conn, pointer} | opts]),
    do: PointerGuard.call(conn, pointer, opts)
  # custom guard mod
  defp guard(conn, [{:guard, guard_mod} | opts]),
    do: guard_mod.call(conn, opts)
  defp guard(conn, [{:via, guard_mod} | opts]),
    do: guard_mod.call(conn, opts)

  defp checkout(conn) do
    state = get_state(conn)
    result = r_checkout(state.bucket, state.limit, state.lifetime)
    put_state(conn, result)
  end

  defp r_checkout(bucket, limit, lifetime) do
    {success, _, remaining, _, reset, _, _} =
      Ralitobu.checkout(bucket, limit, lifetime)
    [success: success, remaining: remaining, reset: in_secs(reset)]
  end

  defp in_secs(msecs),
    do: round(msecs / 1_000)

  alias Ralitobu.Plug.Mixfile
  @version Mixfile.project[:version]
  @doc "Returns the current version of `Ralitobu.Plug`"
  def version, do: @version
end
