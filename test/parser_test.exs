defmodule ParserTest do
  use ExUnit.Case
  doctest Reservations

  test "based parser" do
    assert Reservations.BasedParser.parse("NYC") == {:ok, ["NYC"], "", %{}, {1, 0}, 3}
  end

  test "segment room parser" do
    assert Reservations.SegmentRoomParser.parse("Hotel MAD 2023-02-15 -> 2023-02-17") ==
             {:ok, ["Hotel", "MAD", "2023-02-15", "2023-02-17"], "", %{}, {1, 0}, 34}
  end

  test "segment trip parser" do
    assert Reservations.SegmentTripParser.parse("Train MAD 2023-02-17 17:00 -> SVQ 19:30") ==
             {:ok, ["Train", "MAD", "2023-02-17", "17:00", "SVQ", "19:30"], "", %{}, {1, 0}, 39}
  end
end
