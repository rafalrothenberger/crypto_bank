defmodule BankWeb.ClientView do
  use BankWeb, :view
  alias BankWeb.ClientView

  def render("banned.json", %{received: received, local: local}) do
    %{
      received: received,
      local: local
    }
  end

  def render("params.json", %{p: p, q: q, g: g}) do
    %{
      p: p,
      q: q,
      g: g
    }
  end
end
