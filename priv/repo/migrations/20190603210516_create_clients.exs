defmodule Bank.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :pesel, :string

      timestamps()
    end

  end
end
