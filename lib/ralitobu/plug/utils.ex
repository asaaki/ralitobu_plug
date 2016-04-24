defmodule Ralitobu.Plug.Utils do
  @moduledoc """
  Utility functions
  """

  alias Plug.Conn

  @doc "Find a property value in the Plug.Conn struct"
  def peek(result, []), do: result

  # Conn related
  def peek(%Conn{} = haystack, key) when is_atom(key),
    do: haystack |> Map.get(key)
  def peek(%Conn{} = haystack, [key]),
    do: haystack |> Map.get(key)
  def peek(%Conn{} = haystack, [key|key_chain]),
    do: haystack |> Map.get(key) |> peek(key_chain)

  # generic
  def peek(haystack, key) when is_atom(key),
    do: peek(haystack, [key])
  def peek(haystack, key_chain) do
    Enum.reduce(key_chain, haystack, &haystack_reducer/2)
  end

  defp haystack_reducer(key, collection) do
    Enum.reduce(collection, fn
      {^key, val}, _ -> val
      _, acc -> acc
    end)
  end
end
