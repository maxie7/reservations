defmodule Reservations do
  @moduledoc """
  Documentation for `Reservations`.
  """

  alias Reservations.BasedParser
  alias Reservations.SegmentTripParser
  alias Reservations.SegmentRoomParser

  def process_file(text) do
    lines = String.split(text, ~r{(\r\r|\n|\r)})

    based =
      lines
      |> Enum.filter(&String.starts_with?(&1, "BASED:"))
      |> Enum.map(&String.replace_leading(&1, "BASED: ", ""))
      |> Enum.take(1)
      |> Enum.map(&BasedParser.parse(&1))
      |> get_based()
      |> List.first()

    segment_list =
      lines
      |> Enum.filter(&String.starts_with?(&1, "SEGMENT:"))
      |> Enum.map(&String.replace_leading(&1, "SEGMENT: ", ""))
      |> Enum.map(&parse_segment(String.starts_with?(&1, "Hotel"), &1))
      |> Enum.sort_by(& &1.start_datetime, NaiveDateTime)
      |> Enum.reverse()
      |> group_segments([], nil, nil, based)
      |> Enum.group_by(& &1.trip)

    expose(segment_list)
  end

  defp expose(trip_list) do
    Enum.map(trip_list, fn {trip, reserves} ->
      IO.puts("TRIP to #{trip}")

      Enum.map(reserves, fn res ->
        if res.type == "Hotel", do: print_room_line(res), else: print_trip_line(res)
      end)

      IO.puts("\r")
    end)
  end

  defp group_segments([], result_list, _, _, _), do: result_list

  defp group_segments([head | tail], result_list, _, _, based) when length(result_list) == 0 do
    destination = head.destination

    group_segments(
      tail,
      [Map.put(head, :trip, destination) | result_list],
      head.start_datetime,
      destination,
      based
    )
  end

  defp group_segments([head | tail], result_list, prev_segment_datetime, trip_place, based) do
    if abs(Timex.diff(head.start_datetime, prev_segment_datetime, :day)) <= 7 do
      destination =
        if abs(Timex.diff(head.end_datetime, prev_segment_datetime, :hours)) <= 24 do
          trip_place
        else
          head.destination
        end

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

  defp get_based([based_list | _]) do
    case based_list do
      {:ok, based, _, _, _, _} -> based
      _ -> []
    end
  end

  defp parse_segment(true, segment) do
    case SegmentRoomParser.parse(segment) do
      {:ok, [type, origin, start_date, end_date], _, _, _, _} ->
        %{
          type: type,
          origin: origin,
          start_datetime: Timex.parse!("#{start_date} 23:59", "{YYYY}-{0M}-{0D} {h24}:{m}"),
          end_datetime: Timex.parse!(end_date, "{YYYY}-{0M}-{0D}") |> Timex.to_date()
        }

      {:error, _} ->
        nil
    end
  end

  defp parse_segment(_, segment) do
    case SegmentTripParser.parse(segment) do
      {:ok, [type, origin, start_date, start_time, destination, end_time], _, _, _, _} ->
        %{
          type: type,
          origin: origin,
          start_datetime:
            Timex.parse!("#{start_date} #{start_time}", "{YYYY}-{0M}-{0D} {h24}:{m}"),
          destination: destination,
          end_datetime: Timex.parse!("#{start_date} #{end_time}", "{YYYY}-{0M}-{0D} {h24}:{m}")
        }

      {:error, _} ->
        nil
    end
  end

  defp print_room_line(res) do
    IO.puts(
      "#{res.type} at #{res.origin} on #{Timex.format!(res.start_datetime, "{YYYY}-{0M}-{0D}")} to #{Timex.format!(res.end_datetime, "{YYYY}-{0M}-{0D}")}"
    )
  end

  defp print_trip_line(res) do
    IO.puts(
      "#{res.type} from #{res.origin} to #{res.destination} at #{Timex.format!(res.start_datetime, "{YYYY}-{0M}-{0D} {h24}:{m}")} to #{Timex.format!(res.end_datetime, "{h24}:{m}")}"
    )
  end
end
