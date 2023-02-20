defmodule Reservations do
  @moduledoc """
  Documentation for `Reservations`.
  """

  def start(file) do
    dbg()
    read_file(file)
  end

  defp read_file(text) do
    lines = String.split(text, ~r{(\r\r|\n|\r)})
    words =
      # String.split(text, ~r{(\\n|[^\w'])+})
      String.split(text, ~r{(\\n|[^[:alnum:]'^[:punct:]])+})
      |> Enum.filter(fn x -> x != "" end)

    IO.inspect lines, label: "lines"
    IO.inspect words, label: "words"
  end
end
