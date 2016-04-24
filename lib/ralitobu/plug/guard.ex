defmodule Ralitobu.Plug.Guard do
  @moduledoc """
  `use Ralitobu.Plug.Guard` for your own guard implementations

  It just provides the imported functions also used by Ralitobu.Plug
  itself.
  """

  defmacro __using__(_env) do
    quote do
      import Plug.Conn
      import Ralitobu.Plug.Conn
      import Ralitobu.Plug.Utils
    end
  end
end
