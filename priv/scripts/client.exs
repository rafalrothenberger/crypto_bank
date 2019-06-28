{parsed_options, _}= OptionParser.parse!(System.argv(), switches: [params: :string, clients: :string, data: :string])


defmodule Params do
  defstruct p: nil, q: nil, g: nil

  def parse(json) do
    for element <- json |> String.replace(~r/[{}"]/, "") |> String.split(",") do
      [key, value] = String.split(element, ":")
      {key, value}
    end |> Map.new |> new
  end

  def new(%{"p" => p, "q" => q, "g" => g}) do
    %Params{
      p: Base.decode64!(p) |> :binary.decode_unsigned(),
      q: Base.decode64!(q) |> :binary.decode_unsigned(),
      g: Base.decode64!(g) |> :binary.decode_unsigned()
    }
  end
end

defmodule Data do

end

params_file = Keyword.get(parsed_options, :params, nil)
params = File.read!(params_file) |> Params.parse()
clients = Keyword.get(parsed_options, :clients) |> String.split(",")
data_file = Keyword.get(parsed_options, :data, nil)

mask = if data_file != nil do
  File.read!("/Users/night/.ex_bank_mask") |> :binary.decode_unsigned()
else
  mask = :crypto.mod_pow(params.g, :crypto.rand_uniform(2, params.q), params.p)
  File.write!("/Users/night/.ex_bank_mask", mask, [:binary])
  mask |> :binary.decode_unsigned()
end

# IO.inspect(mask)

defmodule PSI do

  def hash_set(set, params), do: for s <- set, do: :crypto.mod_pow(params.g, hash(s), params.p) |> :binary.decode_unsigned()

  def mask_set(set, params, mask), do: for s <- set, do: :crypto.mod_pow(s, mask, params.p) |> :binary.decode_unsigned()

  def encode(clients) when is_list(clients), do: for client <- clients, do: encode(client)

  def encode(client), do: client |> :binary.encode_unsigned() |> Base.encode64()

  def decode!(clients) when is_list(clients), do: for client <- clients, do: decode!(client)

  def decode!(client), do: client |> Base.decode64!() |> :binary.decode_unsigned()

  def hash(e) do
    :crypto.hash(:sha256, e) |> :binary.decode_unsigned()
  end

end

defmodule PSIData do
  defstruct local: [], received: []
  def parse(json) do
    json
    |> String.replace(~r/[{}"]/, "")
    |> String.replace(~r/,received/, ":received:")
    |> String.replace(~r/,local/, ":local:")
    |> String.split(":")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [key, value] ->
      value = value |> String.replace(~r/[\[\]]/, "") |> String.split(",")
      {key, value}
    end)
    |> Map.new
    |> new
  end

  def new(%{"local" => local, "received" => received}) do
    %PSIData{
      local: local,
      received: received
    }
  end
end

# IO.inspect(masked_clients)

if data_file == nil do
  masked_clients = clients |> PSI.hash_set(params) |> PSI.mask_set(params, mask) |> PSI.encode
  "{\"clients\":[\"" <> Enum.join(masked_clients, "\",\"") <> "\"]}"
else
  data = File.read!(data_file)
  data = data |> PSIData.parse()
  # IO.inspect(data)
  local = data.local |> PSI.decode! |> PSI.mask_set(params, mask) |> PSI.encode
  for {e1,e2} <- Enum.zip(clients, data.received), e2 in local, do: e1
end
|> IO.puts()
