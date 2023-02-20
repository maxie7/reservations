defmodule Reservations.CLI do
  def main(_args) do
    file_to_string = IO.read(:stdio, :all)

    Reservations.start(file_to_string)
  end
end
