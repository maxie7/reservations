# Reservations

## Objective

As we want to provide a better experience for our users we want to represent their itinerary in the most comprehensive way possible.

We receive the reservations of our user that we know is based on SVQ as:

```
BASED: SVQ

RESERVATION
SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10

RESERVATION
SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10

RESERVATION
SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10
SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50

RESERVATION
SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00
SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30

RESERVATION
SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17

RESERVATION
SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45
```

But we want to expose the following format:

```
TRIP to BCN
Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
Hotel at BCN on 2023-01-05 to 2023-01-10
Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

TRIP to MAD
Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
Hotel at MAD on 2023-02-15 to 2023-02-17
Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

TRIP to NYC
Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
```

We want an Elixir program that gets the input from the file `input.txt` and prints the expected output.

Take into account the following aspects:

- You should implement the sort and grouping logic of the segments. 
- You can assume that segments won’t overlap. 
- IATAs are always three-letter capital words: SVQ, MAD, BCN, NYC 
- You can use external libraries if you want. 
- You can attach notes explaining the solution and why certain things are included and others are left out. 
- You may consider two flights to be a connection if there is less than 24 hours difference.


## Solution

There are different approaches could be used to solve the current problem like regular expressions, binary pattern matching or parser combinators. The last one has various libs: `NimbleParsec`, `Combine`, `Ergo`.

We'll use the NimbleParsec because it's simple, fast and pretty well known library in Elixir community.

The idea is to get the input txt file, process it line by line and parse the raw information to structured data in order to manipulate it. When the data is sorted and grouped we just output it.

Elixir uses the `escript` to build executable files which run as a normal shell scrips. Its only dependency is Erlang to be installed in your machine. Elixir is not necessary, since `escript` embeds Elixir into compiled app.

The schema is the following:

`output.txt` -> `elixir escript` -> `output in the necessary format`

The segment sample map (parsed from the text file) will look like this:

```elixir
%{ type: "Flight" | "Trian" | "Hotel",
   origin: "XXX",
   trip: tag to group data (we add it when processing data),
   start_datetime: ~N[2023-03-02 09:10:00],
   destination: "YYY" (it's not presented for "Hotel" type'),
   end_datetime: ~N[2023-03-05 09:10:00] }
```

## Installation


```elixir
mix deps.get

mix escript.build

cat input.txt | ./reservations 
```

You can just run the last command `cat input.txt | ./reservations` because the compiled file already exists in the repo.

### Timex with escript

If you need to use Timex from within an escript, add `{:tzdata, "~> 0.1.8", override: true}` to your deps, more recent versions of :tzdata are unable to work in an escript because of the need to load ETS table files from priv, and due to the way ETS loads these files, it's not possible to do so.

If your build still throws an error after this, try removing the `_build` and `deps` folder. Then execute `mix deps.unlock tzdata` and `mix deps.get`.

P.S. You could note warning when compiling the project. It happens because of `timex` and `tzdata` (last versions) incompatibility. 
