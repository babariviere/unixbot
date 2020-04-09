defmodule Reddit.Listing do
  @moduledoc """
  Module to manipulate reddit listing.
  """

  defstruct [:after, :before, :children]
  @expected_fields ~w(after before children)

  @type t(child) :: %__MODULE__{
          after: String.t() | nil,
          before: String.t() | nil,
          children: list(child)
        }

  @doc """
  Convert a JSON map to a listing data.

  An optional mapper can be given as an argument to map all children.
  """
  @spec from_json(map(), (any() -> any()) | nil) :: t(any())
  def from_json(%{"data" => data, "kind" => "Listing"}, mapper \\ nil) do
    data =
      data
      |> Map.take(@expected_fields)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    listing = struct(__MODULE__, data)

    if mapper do
      %__MODULE__{listing | children: Enum.map(listing.children, mapper)}
    else
      listing
    end
  end
end

defimpl Enumerable, for: Reddit.Listing do
  alias Reddit.Listing

  def count(%Listing{children: children}) do
    {:ok, Enum.count(children)}
  end

  def member?(%Listing{children: children}, element) do
    {:ok, Enum.member?(children, element)}
  end

  def reduce(%Listing{children: children}, acc, fun) do
    Enum.reduce(children, acc, fun)
  end

  def slice(_listing) do
    # we don't know the size without doing Enum.count
    {:error, __MODULE__}
  end
end
