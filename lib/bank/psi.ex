defmodule Bank.Psi do
  use Overridable
  alias Overridable.Strategy.SchnorrGroup

  @params SchnorrGroup.gen_params(1024)
  @g SchnorrGroup.new(@params)

  def hash_set(set) do
    for s <- set, do: pow(@g, hash(s))
  end

  def generate_mask() do
    SchnorrGroup.random_q(@g)
  end

  def mask_set(set, mask) do
    for s <- set, do: pow(s, mask)
  end

  def params do
    {p, q, _r} = @params
    %{
      p: p |> :binary.encode_unsigned() |> Base.encode64(),
      q: q |> :binary.encode_unsigned() |> Base.encode64(),
      g: @g |> to_bin() |> Base.encode64(),
    }
  end

  defp hash(e) when is_binary(e) do
    :crypto.hash(:sha256, e) |> :binary.decode_unsigned()
  end

  defp hash(_e) do
    raise "You what mate?"
  end

end
