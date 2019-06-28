defmodule BankWeb.ClientController do
  use BankWeb, :controller

  alias Bank.Accounts
  alias Bank.Accounts.Client
  alias Bank.Psi

  action_fallback BankWeb.FallbackController

  def params(conn,%{}) do
    render conn, "params.json", Psi.params()
  end

  def banned(conn, %{"clients" => req_clients}) do
    req_clients = for req_client <- req_clients, do: decode!(req_client)
    mask = Psi.generate_mask()
    local_clients = Accounts.list_clients()
    req_clients = req_clients |> Psi.mask_set(mask) |> encode!()
    local_clients = local_clients |> Psi.hash_set() |> Psi.mask_set(mask) |> encode!()
    render conn, "banned.json", %{received: req_clients, local: local_clients}
  end

  defp decode!(clients) when is_list(clients) do
    for client <- clients, do: decode!(client)
  end

  defp decode!(client), do: client |> Base.decode64!() |> :binary.decode_unsigned()

  defp encode!(clients) when is_list(clients) do
    for client <- clients, do: encode!(client)
  end

  defp encode!(client), do: client |> Overridable.to_bin() |> Base.encode64()
end
