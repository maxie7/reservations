defmodule Reservations do
  @moduledoc """
  The main module for processing `Reservations`.
  """

  @spec process_file(String.t() | {:error, term()} | :eof | any()) :: any()
  def process_file(text) do
    lines = String.split(text, ~r{(\r\r|\n|\r)})

    based_chunk_fun = &based_logic(&1, &2)
    segment_chunk_fun = &chunk_logic(&1, &2)
    after_fun = &{:cont, &1, nil}

    based =
      lines
      |> Enum.chunk_while([], based_chunk_fun, after_fun)
      |> List.flatten()
      |> List.first()

    segment_list =
      lines
      |> Enum.chunk_while([], segment_chunk_fun, after_fun)
      |> List.flatten()
      |> Enum.sort_by(& &1.start_datetime, NaiveDateTime)
      |> Enum.reverse()
      |> group_segments([], nil, nil, based)
      |> Enum.group_by(& &1.trip)

    #    IO.inspect segment_l, label: "SEGMENT L: "

    expose(segment_list)
  end

  defp based_logic(<<"BASED: ", based::binary-size(3), _rest::binary>>, acc) do
    {:cont, [based | acc]}
  end

  defp based_logic(_, acc), do: {:cont, acc}

  defp chunk_logic(
         <<"SEGMENT: Flight ", origin::binary-size(3), " ", start_dt::binary-size(16), " -> ",
           dest::binary-size(3), " ", end_time::binary>>,
         acc
       ) do
    segment_map = get_trip_map("Flight", origin, start_dt, dest, end_time)
    {:cont, [segment_map | acc]}
  end

  defp chunk_logic(
         <<"SEGMENT: Train ", origin::binary-size(3), " ", start_dt::binary-size(16), " -> ",
           dest::binary-size(3), " ", end_time::binary>>,
         acc
       ) do
    segment_map = get_trip_map("Train", origin, start_dt, dest, end_time)
    {:cont, [segment_map | acc]}
  end

  defp chunk_logic(
         <<"SEGMENT: Hotel ", origin::binary-size(3), " ", start_dt::binary-size(10), " -> ",
           end_date::binary>>,
         acc
       ) do
    segment_map = %{
      type: "Hotel",
      origin: origin,
      # check in in hotels is usually until midnight
      start_datetime: NaiveDateTime.from_iso8601!(start_dt <> " 23:59:59"),
      # check out in hotels is usually until afternoon
      end_datetime: NaiveDateTime.from_iso8601!(end_date <> " 11:59:59")
    }

    {:cont, [segment_map | acc]}
  end

  defp chunk_logic(_el, acc), do: {:cont, acc}

  defp get_trip_map(trip_type, origin, start_dt, dest, end_time) do
    start_datetime = NaiveDateTime.from_iso8601!(start_dt <> ":00")
    trip_date = NaiveDateTime.to_date(start_datetime)

    %{
      type: trip_type,
      origin: origin,
      start_datetime: start_datetime,
      destination: dest,
      end_datetime: NaiveDateTime.new!(trip_date, Time.from_iso8601!(end_time <> ":00"))
    }
  end

  @spec expose(map) :: any
  defp expose(trip_list) do
    Enum.map(trip_list, fn {trip, reserves} ->
      IO.puts("TRIP to #{trip}")
      expose_reserves(reserves)
      IO.puts("\r")
    end)
  end

  @spec expose_reserves(list) :: [any()]
  defp expose_reserves(reserves) do
    Enum.map(reserves, fn res ->
      if res.type == "Hotel", do: print_room_line(res), else: print_trip_line(res)
    end)
  end

  defp group_segments([], result_list, _, _, _), do: result_list

  defp group_segments([head | tail], [], _, _, based) do
    destination = head.destination

    group_segments(
      tail,
      [Map.put(head, :trip, destination) | []],
      head.start_datetime,
      destination,
      based
    )
  end

  defp group_segments([head | tail], result_list, prev_segment_datetime, trip_place, based) do
    if abs(NaiveDateTime.diff(head.start_datetime, prev_segment_datetime, :day)) <= 7 do
      destination =
        get_destination(
          abs(NaiveDateTime.diff(head.end_datetime, prev_segment_datetime, :hour)) <= 24,
          trip_place,
          head
        )

      group_segments(
        tail,
        [Map.put(head, :trip, destination) | result_list],
        head.start_datetime,
        destination,
        based
      )
    else
      destination = if head.destination == based, do: head.origin, else: head.destination

      group_segments(
        tail,
        [Map.put(head, :trip, destination) | result_list],
        head.start_datetime,
        destination,
        based
      )
    end
  end

  @spec get_destination(boolean, binary, atom | binary | map) :: binary
  defp get_destination(true, trip_place, _), do: trip_place
  defp get_destination(_, _, head), do: head.destination

  defp print_room_line(res) do
    IO.puts(
      "#{res.type} at #{res.origin} on #{Date.to_string(NaiveDateTime.to_date(res.start_datetime))} to #{Date.to_string(NaiveDateTime.to_date(res.end_datetime))}"
    )
  end

  defp print_trip_line(res) do
    IO.puts(
      "#{res.type} from #{res.origin} to #{res.destination} at #{NaiveDateTime.to_string(res.start_datetime) |> String.replace_suffix(":00", "")} to #{Time.to_string(NaiveDateTime.to_time(res.end_datetime)) |> String.replace_suffix(":00", "")}"
    )
  end
end
