defmodule Reservations do
  @moduledoc """
  Documentation for `Reservations`.
  """

  alias Reservations.SegmentTripParser
  alias Reservations.SegmentRoomParser

  def start(file), do: process_file(file)

  defp process_file(text) do
    lines = String.split(text, ~r{(\r\r|\n|\r)})

    segment_list =
      lines
      |> Enum.filter(&(String.starts_with?(&1, "SEGMENT:")))
      |> Enum.map(&(String.replace_leading(&1, "SEGMENT: ", "")))

    IO.inspect segment_list, label: "segment_list"
    segments = Enum.map(segment_list, &(parse_segment(String.starts_with?(&1, "Hotel"), &1)))
    IO.inspect segments, label: "segments"
  end

  defp parse_segment(true, segment), do: SegmentRoomParser.parse(segment)
  defp parse_segment(_, segment), do: SegmentTripParser.parse(segment)
end
