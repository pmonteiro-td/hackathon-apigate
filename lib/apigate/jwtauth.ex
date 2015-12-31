require Logger

defmodule Apigate.Plug.JWTAuth do
  @behaviour Plug
  import Plug.Conn

  use Timex

  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, opts) do
    key = Keyword.get(opts, :key, "")
    try do
      case JsonWebToken.verify(get_token(conn), %{key: key}) do
        {:ok, claims}    -> process_claims(conn, claims)
        {:error, reason} -> Logger.info "Token error: #{reason}"
      end
    rescue
      RuntimeError -> Logger.info "Error verifying token."
      conn
    end
  end

  defp process_claims(conn, claims) do
    valid = check_expiration(claims) && check_issuer(claims)
    if valid do
      scope = %{
        account_id: claims[:aid],
        account: claims[:acc],
        user: claims[:usr],
      }
      Logger.info "Scope: Account #{scope[:account]}, User #{scope[:user]}"
      Plug.Conn.put_req_header conn, "scope", Poison.encode!(scope)
    end
    conn
  end

  defp get_token(conn) do
    headers = conn.req_headers |> Enum.into %{}
    header = headers["authorization"]
    if header do
      token = String.split(header, " ") |> Enum.at 1
      Logger.debug "Got token #{token}."
    else
      token = ""
      Logger.info "Token not found."
    end
    token
  end

  defp check_expiration(claims) do
    {:ok, expires} = claims[:exp] |> DateFormat.parse("%Y-%m-%d %H:%M:%S", :strftime)
    Date.compare(expires, Date.now) == 1
  end

  defp check_issuer(claims) do
    claims[:iss] == "Elixir.AuthSystem"
  end

  #@spec put_resp_headers(Plug.Conn.t, [{String.t, String.t}]) :: Plug.Conn.t
  #defp put_resp_headers(conn, []), do: conn
  #defp put_resp_headers(conn, [{header, value}|rest]) do
#    conn
#      |> Plug.Conn.put_resp_header(header |> String.downcase, value)
#      |> put_resp_headers(rest)
#  end

end
