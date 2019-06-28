defmodule Bank.Sessions do
  use GenServer
  alias Bank.Psi

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call(:new, _from, sessions) do
    uuid = Ecto.UUID.generate()
    mask = Psi.generate_mask()
    session = {uuid,mask}
    {:reply, session, [session|sessions]}
  end

  @impl true
  def handle_call({:get, uuid}, _from, sessions) do
    {
      :reply,
      case for {session_uuid, mask} <- sessions, session_uuid == uuid, do: {session_uuid, mask} do
        [session] -> session
        [] -> :session_not_exist_or_expired
      end,
      sessions
    }
  end

end
