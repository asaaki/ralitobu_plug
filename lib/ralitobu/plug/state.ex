defmodule Ralitobu.Plug.State do
  @moduledoc """
  State struct for the plug (stored in conn.private)
  """

  @doc false
  defstruct ~w(
    bucket limit lifetime
    success remaining reset
  )a
end
