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

    segment_list =
      lines
      |> Enum.filter(&String.starts_with?(&1, "SEGMENT:"))
      |> Enum.map(&String.replace_leading(&1, "SEGMENT: ", ""))
      |> Enum.map(&parse_segment(String.starts_with?(&1, "Hotel"), &1))

    sorted_segments = Enum.sort_by(segment_list, & &1.start_datetime, NaiveDateTime)

    grouped_segments = group_segments(Enum.reverse(sorted_segments), [], nil, nil)

    IO.inspect(sorted_segments, label: "sorted_segments")
    IO.inspect(grouped_segments, label: "grouped_segments")
    IO.inspect(based, label: "BASED")
  end

  defp group_segments([], result_list, _, _), do: result_list

  defp group_segments([head | tail], result_list, _, _) when length(result_list) == 0 do
    destination = String.to_atom(head.destination)
    group_segments(tail, [%{destination => head} | result_list], head.start_datetime, destination)
  end

  defp group_segments([head | tail], result_list, prev_segment_datetime, trip_place) do
    if abs(Timex.diff(head.start_datetime, prev_segment_datetime, :day)) <= 7 do
      destination =
        if abs(Timex.diff(head.end_datetime, prev_segment_datetime, :hours)) <= 24 do
          trip_place
        else
          String.to_atom(head.destination)
        end

      group_segments(tail, [%{destination => head} | result_list], head.start_datetime, destination)
    else

      destination = if head.destination == "SVQ", do: String.to_atom(head.origin), else: String.to_atom(head.destination)
      group_segments(
        tail,
        [%{destination => head} | result_list],
        head.start_datetime,
        destination
      )
    end
  end

  defp get_based([based_list | _]) do
    case based_list do
      {:ok, based, _, _, _, _} -> based
      _ -> nil
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
          start_datetime: Timex.parse!("#{start_date} #{start_time}", "{YYYY}-{0M}-{0D} {h24}:{m}"),
          destination: destination,
          end_datetime: Timex.parse!("#{start_date} #{end_time}", "{YYYY}-{0M}-{0D} {h24}:{m}")
        }

      {:error, _} ->
        nil
    end
  end
end
