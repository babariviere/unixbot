defmodule Unixbot.Command do
  alias Nostrum.Struct.Message

  @callback execute(Arguments.t(), Message.t()) :: no_return() | Message.t()

  defmodule Arguments do
    @moduledoc """
    Define command line arguments.

    # Example

    For the given command: `subscribe unixbot frequency:daily`.
    Arguments will be: `%Arguments{values: ["unixbot"], params: %{frequency: "daily"}}`
    """

    defstruct [:values, :params]

    @type t() :: %__MODULE__{
            values: list(),
            params: map()
          }
  end

  defmacro __using__(_args) do
    quote do
      @behaviour Unixbot.Command

      alias Unixbot.Command.Arguments

      alias Nostrum.Api

      alias Nostrum.Struct.{
        Embed,
        Message,
        User
      }
    end
  end

  @doc """
  Parse a command and convert it to a list of arguments.

  # Example

      iex> Unixbot.Command.parse("subscribe unixbot 19h00 frequency:daily")
      {"subscribe",
        %Unixbot.Command.Arguments{
          params: %{"frequency" => "daily"},
          values: ["unixbot", "19h00"]
        }}
  """
  @spec parse(String.t()) :: {String.t(), Arguments.t()}
  def parse(content) do
    cl = String.to_charlist(content)
    {cmd, rest} = parse_command(cl)
    cmd = to_string(cmd)

    args =
      rest
      |> parse_arguments()
      |> Enum.reduce(%Arguments{values: [], params: %{}}, fn
        {arg, val}, %Arguments{params: params} = acc ->
          %{acc | params: Map.put(params, to_string(arg), to_string(val))}

        arg, %Arguments{values: values} = acc ->
          %Arguments{acc | values: values ++ [to_string(arg)]}
      end)

    {cmd, args}
  end

  @spec parse_command(charlist()) :: {charlist(), charlist()}
  defp parse_command(content) do
    Enum.split_while(content, &(&1 in ?a..?z or &1 == ?_))
  end

  defp parse_arguments(content) do
    content = Enum.drop_while(content, &(&1 == ?\s))

    {arg, rest} = parse_argument(content)

    if rest == [] do
      [arg]
    else
      [arg | parse_arguments(rest)]
    end
  end

  defp parse_argument([?" | content]) do
    {arg, rest} = Enum.split_while(content, &(&1 != ?: and &1 != ?"))

    case rest do
      [?: | tl] ->
        {val, rest} = Enum.split_while(tl, &(&1 != ?"))
        {{arg, val}, Enum.drop(rest, 1)}

      [?" | tl] ->
        {arg, tl}

      _ ->
        {arg, rest}
    end
  end

  defp parse_argument(content) do
    {arg, rest} = Enum.split_while(content, &(&1 != ?: and &1 != ?\s))

    case rest do
      [?:, ?" | tl] ->
        {val, rest} = Enum.split_while(tl, &(&1 != ?"))
        {{arg, val}, Enum.drop(rest, 1)}

      [?: | tl] ->
        {val, rest} = Enum.split_while(tl, &(&1 != ?\s))
        {{arg, val}, rest}

      _ ->
        {arg, rest}
    end
  end
end
