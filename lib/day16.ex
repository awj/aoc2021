defmodule Day16 do
  @hexmap %{
    "0" => <<0::1,0::1,0::1,0::1>>,
    "1" => <<0::1,0::1,0::1,1::1>>,
    "2" => <<0::1,0::1,1::1,0::1>>,
    "3" => <<0::1,0::1,1::1,1::1>>,
    "4" => <<0::1,1::1,0::1,0::1>>,
    "5" => <<0::1,1::1,0::1,1::1>>,
    "6" => <<0::1,1::1,1::1,0::1>>,
    "7" => <<0::1,1::1,1::1,1::1>>,
    "8" => <<1::1,0::1,0::1,0::1>>,
    "9" => <<1::1,0::1,0::1,1::1>>,
    "A" => <<1::1,0::1,1::1,0::1>>,
    "B" => <<1::1,0::1,1::1,1::1>>,
    "C" => <<1::1,1::1,0::1,0::1>>,
    "D" => <<1::1,1::1,0::1,1::1>>,
    "E" => <<1::1,1::1,1::1,0::1>>,
    "F" => <<1::1,1::1,1::1,1::1>>,
  }

  def decode([val | []]) do
    << @hexmap[val] :: bitstring >>
  end

  def decode([val | vals]) do
    << @hexmap[val] :: bitstring, decode(vals) :: bitstring >>
  end

  def decode(input) do
    decode(String.graphemes(input))
  end

  def display(bits, result \\ [])

  def display(<< n :: 1 >>, result), do: result ++ [n]

  def display(<< n :: 1, rest :: bits>>, result) do
    display(rest, result ++ [n])
  end

  def version_total({:literal, version, _type, _value}) do
    version
  end

  def version_total({_some_container, version, _type, parts}) do
    version + (Enum.map(parts, &version_total/1) |> Enum.sum)
  end

  def evaluate({_key, _version, 0, parts}) do
    parts
    |> Enum.map(&evaluate/1)
    |> Enum.sum
  end

  def evaluate({_key, _version, 1, parts}) do
    parts
    |> Enum.map(&evaluate/1)
    |> Enum.product
  end

  def evaluate({_key, _version, 2, parts}) do
    parts
    |> Enum.map(&evaluate/1)
    |> Enum.min
  end

  def evaluate({_key, _version, 3, parts}) do
    parts
    |> Enum.map(&evaluate/1)
    |> Enum.max
  end

  def evaluate({_key, _version, 4, val}) do
    val
  end

  def evaluate({_key, _version, 5, [p1, p2 | _rest]}) do
    if evaluate(p1) > evaluate(p2) do
      1
    else
      0
    end
  end

  def evaluate({_key, _version, 6, [p1, p2 | _rest]}) do
    if evaluate(p1) < evaluate(p2) do
      1
    else
      0
    end
  end

  def evaluate({_key, _version, 7, [p1, p2 | _rest]}) do
    if evaluate(p1) == evaluate(p2) do
      1
    else
      0
    end
  end

  def to_integer(bits) do
    size = bit_size(bits)

    <<val :: integer-size(size) >> = bits

    val
  end

  def parse(<< version :: 3, 4 :: 3, rest :: bits >>) do
    parse_literal(version, rest, 6)
  end

  def parse(<< version :: 3, type :: 3, flag :: 1, rest :: bits>>) do
    if flag == 0 do
      << len :: bits-size(15), rest :: bits >> = rest
      len = to_integer(len)

      parse_length_container(version, type, len, rest, 22)
    else
      << len :: bits-size(11), rest :: bits >> = rest
      len = to_integer(len)

      parse_count_container(version, type, len, rest, 18)
    end
  end

  def parse_count_container(version, type, len, rest, bits_consumed, parts \\ [])

  def parse_count_container(version, type, 0, rest, bits_consumed, parts) do
    container = {:count_container, version, type, parts}

    { container, bits_consumed, rest }
  end

  def parse_count_container(version, type, len, rest, bits_consumed, parts) do
    {element, consumed, remaining} = parse(rest)

    parse_count_container(version, type, len - 1, remaining, bits_consumed + consumed, parts ++ [element])
  end
  
  def parse_length_container(version, type, len, bits, bits_consumed) do
    << slice :: bits-size(len), rest :: bits >> = bits

    bits_consumed = bits_consumed + len

    container = {:length_container, version, type, length_parts(slice)}

    { container, bits_consumed, rest }
  end

  def length_parts(bits, prev \\ [])

  def length_parts(<<>>, prev) do
    prev
  end

  def length_parts(bits, prev) do
    {elem, _consumed, remainder} = parse(bits)

    length_parts(remainder, prev ++ [elem])
  end

  def parse_literal(version, remainder, bits_consumed) do
    {val, consumed, remainder} = parse_literal_value(remainder, <<>>, bits_consumed)

    element = {:literal, version, 4, to_integer(val)}
    {element, bits_consumed + consumed, remainder}
  end

  def parse_literal_value(bitstream, output, bits_read)

  def parse_literal_value(<<1::1, digits :: bits-size(4), remainder :: bits>>, output, bits_read) do
    parse_literal_value(remainder, <<output :: bits, digits :: bits>>, bits_read + 5)
  end

  def parse_literal_value(<<0::1, digits :: bits-size(4), remainder :: bits>>, output, bits_read) do
    final = <<output :: bits, digits :: bits>>

    { final, bits_read + 5, remainder }
  end
 end
