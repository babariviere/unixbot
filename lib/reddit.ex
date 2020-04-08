defmodule Reddit do
  @moduledoc """
  Reddit API Wrapper
  """

  use HTTPoison.Base

  @oauth_endpoint "https://oauth.reddit.com"

  @impl true
  def process_request_url(url) do
    @oauth_endpoint <> url
  end

  @impl true
  def process_request_headers(headers) do
    token = Reddit.TokenServer.get_token()

    [Authorization: "Bearer #{token}", "User-Agent": "Unixbot"] ++ headers
  end

  @impl true
  def process_response_body(body) do
    Poison.decode!(body)
  end

  @doc """
  Get information about current user.
  """
  @spec me() :: {:ok, map()} | nil
  def me() do
    get("/api/v1/me")
  end

  @type listing :: [
          t: :hour | :day | :week | :month | :year | :all,
          after: String.t(),
          before: String.t(),
          limit: non_neg_integer(),
          count: non_neg_integer()
        ]

  @doc """
  Query a list of posts from the subreddit.
  """
  @spec subreddit(String.t(), :top | :hot | :new | :rising, listing) ::
          {:ok, Reddit.Listing.t(Reddit.Post.t())} | nil
  def subreddit(name, sort \\ :top, params \\ []) do
    case get("/r/#{name}/#{sort}", [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Reddit.Listing.from_json(body, &Reddit.Post.from_json/1)}

      _ ->
        nil
    end
  end
end
