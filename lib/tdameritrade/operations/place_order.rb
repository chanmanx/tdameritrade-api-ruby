require 'tdameritrade/operations/base_operation'

module TDAmeritrade; module Operations
  class PlaceOrder < BaseOperation
    #include Support::BuildOrderItems

    def call(account_id, symbol, quantity)
      # market order for now, add support for limit later
      body = {
        "orderType": "MARKET",
        "session": "NORMAL",
        "duration": "DAY",
        "orderStrategyType": "SINGLE",
        "orderLegCollection": [
          {
            "instruction": "Buy",
            "quantity": quantity,
            "instrument": {
              "symbol": symbol,
              "assetType": symbol.length == 5 ? "MUTUAL_FUND" : "EQUITY"
            }
          }
        ]
      }.to_json

      uri = URI("https://api.tdameritrade.com/v1/accounts/#{account_id}/orders")
      request = Net::HTTP::Post.new(
        uri.path,
        'authorization' => "Bearer #{client.access_token}",
        'content-type' => 'application/json'
      )
      request.body = body
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

      if response_success?(response)
        true
      else
        parse_api_response(response)
      end
    end

  end
end; end