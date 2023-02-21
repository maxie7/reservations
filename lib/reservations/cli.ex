defmodule Reservations.CLI do
  @moduledoc """
  It builds an executable file which runs as a normal shell script.
  """

  @spec main(list) :: term()
  def main(_args) do
    :stdio
    |> IO.read(:all)
    |> Reservations.process_file()
  end
end
