defmodule Reservations.SegmentRoomParser do
  @moduledoc false

  import NimbleParsec

  type = string("Hotel")
  iata = utf8_string([?A..?Z], 3)
  date = utf8_string([], 10)

  segment_code =
    type
    |> ignore(string(" "))
    |> concat(iata)
    |> ignore(string(" "))
    |> concat(date)
    |> ignore(string(" -> "))
    |> concat(date)

  defparsec(:parse, segment_code)
end
