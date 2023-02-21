defmodule Reservations.BasedParser do
  @moduledoc false

  import NimbleParsec

  iata = utf8_string([?A..?Z], 3)

  based =
    string("")
    |> ignore()
    |> concat(iata)

  defparsec(:parse, based)
end
