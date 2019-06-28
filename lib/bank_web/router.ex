defmodule BankWeb.Router do
  use BankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankWeb do
    pipe_through :api

    get "/clients/params", ClientController, :params
    post "/clients/banned", ClientController, :banned
  end
end
