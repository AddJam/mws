defmodule Mws.Parser do

  @moduledoc """
  """

  def handle_response({:ok, %{body: body, headers: headers, status_code: _code}}) do
    body =
      case get_content_type(headers) do
        "text/xml"                        -> parse_xml(body)
        "text/xml;charset=" <> _charset   -> parse_xml(body)
        "text/plain;charset=" <> _charset ->
          body
          |> String.split("\r\n")
          |> CSV.decode(seperator: ?\t, headers: true)
        _ -> body
      end

    # Turn the headers into a map
    headers =
      headers
      |> Enum.reduce(%{}, fn({k, v}, acc) ->
        Map.put(acc, k, v)
      end)

    %{headers: headers, body: body}
  end

  defp parse_xml(xml) do
    xml
    |> Mws.XsltTransformer.strip_namespaces
    |> XmlToMap.naive_map
  end

  def get_content_type(headers) do
    Enum.find_value headers, fn
      {"Content-Type", value} -> value
      _ -> false
    end
  end
end
