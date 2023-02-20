defmodule Reservations.SegmentTripParser do
  @moduledoc false

  import NimbleParsec

  type = choice([string("Train"), string("Flight")])
  iata = utf8_string([?A..?Z], 3)
  date = utf8_string([], 10)
  time = utf8_string([], 5)

  segment_code =
    type
    |> ignore(string(" "))
    |> concat(iata)
    |> ignore(string(" "))
    |> concat(date)
    |> ignore(string(" "))
    |> concat(time)
    |> ignore(string(" -> "))
    |> concat(iata)
    |> ignore(string(" "))
    |> concat(time)

  defparsec(:parse, segment_code)
end
