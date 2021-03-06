defmodule Mws.ClientTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
    {:ok, conn} = %Mws.Config{
      endpoint:         Application.get_env(:mws, :endpoint),
      seller_id:        Application.get_env(:mws, :seller_id),
      marketplace_id:   Application.get_env(:mws, :marketplace_id),
      access_key_id:    Application.get_env(:mws, :access_key_id),
      secret_key:       Application.get_env(:mws, :secret_key),
      mws_auth_token:   Application.get_env(:mws, :mws_auth_token)
    }
    |> Mws.Client.start_link

    {:ok, conn: conn}
  end

  test "Can make a connection to MWS", ctx do
    use_cassette "get_matching_product" do
      query =
        %{
          "Action"   => "GetMatchingProduct",
          "Version"  => "2011-10-01",
          "ASINList" => ["B017R5CP1C"]
        }
        |> Mws.Utils.restructure("ASINList", "ASIN")

      url = %URI{
        path: "/Products/2011-10-01",
        query: query
      }

    resp = Mws.Client.request(ctx[:conn], :post, url)

    assert get_in(resp, ["GetMatchingProductResponse", "GetMatchingProductResult", "status"]) == "Success"
   end
  end
end

