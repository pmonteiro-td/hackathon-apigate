require Logger

defmodule Apigate.Plug.Proxy do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, opts) do
    scope = Keyword.get(opts, :scope, '')
    to = Keyword.get(opts, :to, '')
    headers = Keyword.get(opts, :headers, [])

    Logger.info "scope #{scope}"
    Logger.info "to #{to}"

    #require IEx; IEx.pry

    url = conn.request_path |> String.slice(String.length(scope)..-1)
    url = "#{to}/#{url}"
    method = conn.method
    body = conn.body_params |> Plug.Conn.Query.encode

    Logger.info "PROXY REQUEST #{method} #{url} "

    HTTPoison.request(method, url, body, headers) |> process_response(conn)
  end

  @spec process_response({Atom.t, Map.t}, Plug.Conn.t) :: Plug.Conn.t
  defp process_response({:error, _}, conn) do
    conn |> Plug.Conn.send_resp(502, "Bad Gateway")
  end
  defp process_response({:ok, response}, conn) do
    conn
      |> put_resp_headers(response.headers)
      |> Plug.Conn.send_resp(response.status_code, response.body)
  end

  @spec put_resp_headers(Plug.Conn.t, [{String.t, String.t}]) :: Plug.Conn.t
  defp put_resp_headers(conn, []), do: conn
  defp put_resp_headers(conn, [{header, value}|rest]) do
    conn
      |> Plug.Conn.put_resp_header(header |> String.downcase, value)
      |> put_resp_headers(rest)
  end

end
