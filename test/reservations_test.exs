defmodule ReservationsTest do
  use ExUnit.Case
  doctest Reservations

  test "process file function" do
    assert Reservations.process_file(
             "BASED: SVQ\n\nRESERVATION\nSEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n\nRESERVATION\nSEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n\nRESERVATION\nSEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10\nSEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50\n\nRESERVATION\nSEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00\nSEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30\n\nRESERVATION\nSEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17\n\nRESERVATION\nSEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45\n"
           ) == [:ok, :ok, :ok]
  end
end
