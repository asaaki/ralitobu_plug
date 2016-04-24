defmodule Ralitobu.Plug.Conn do
  @moduledoc """
  Ralitobu.Plug specific connection helper functions
  """

  import Plug.Conn
  alias Ralitobu.Plug.State
  @state_key :ralitobu_plug

  def get_state(conn),
    do: Dict.get(conn.private, @state_key, %State{})

  def get_state_value(conn, key, default \\ nil),
    do: Map.get(get_state(conn), key, default)

  def put_state(conn, key, value),
    do: put_state(conn, [{key, value}])
  def put_state(conn, kv_list),
    do: put_private(conn, @state_key, struct(get_state(conn), kv_list))

  # Why no "x-" prefix? -> http://tools.ietf.org/html/bcp178
  def put_ratelimit_headers(conn) do
    state = get_state(conn)
    conn
    |> put_resp_header("ratelimit-limit", to_string(state.limit))
    |> put_resp_header("ratelimit-remaining", to_string(state.remaining))
    |> put_resp_header("ratelimit-reset", to_string(state.reset))
  end

  def pass_or_halt(conn),
    do: do_pass_or_halt(conn, get_state_value(conn, :success))

  defp do_pass_or_halt(conn, nil), do: conn
  defp do_pass_or_halt(conn, :ok), do: conn
  defp do_pass_or_halt(conn, :error) do
    state = get_state(conn)
    s_reset = to_string(state.reset)
    conn
    |> put_resp_header("retry-after", s_reset)
    |> put_resp_content_type("application/json")
    |> send_resp(429, error_json(s_reset))
    |> halt
  end

  defp error_json(reset_timer) do
    """
    ~s({"status": 429, "error": "Too Many Requests", "retry_after": #{reset_timer}})
    """
  end
  # --- not sure about the wording ---
  # defp error_json(reset_timer) do
  #   "{"
  #   <> ~S("status": 429, )
  #   <> ~S("error": "Too Many Requests", )
  #   <> ~s("retry_after": #{reset_timer},\n)
  #   <> ~S( "message": "Please respect the rate limit and check the HTTP headers)
  #   <> ~S( to adjust your client's behaviour accordingly.")
  #   <> "}\n"
  # end
end
