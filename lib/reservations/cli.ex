defmodule Reservations.CLI do
  @moduledoc false

  def main(_args) do
    file_to_string = IO.read(:stdio, :all)

    Reservations.process_file(file_to_string)
  end
end
