require 'coinbase/exchange'
require 'base64'
require 'openssl'
require 'json'
require 'net/http'
require 'uri'
require 'thread'


class Make_Money

  def initialize(coin)

    @crypto = coin
    @api_key = ""
    @api_secret = ""
    @api_pass = ""
    @fiat = "USD"
    @product_id = @crypto + "-" + @fiat
    @exchange_url = "https://api.pro.coinbase.com"
    @wallet_url = "https://api.coinbase.com"
    @easy = Coinbase::Exchange::Client.new(@api_key, @api_secret, @api_pass, api_url: @exchange_url)
    @log_file = coin+"_log.txt"
    @lock = Mutex.new


  end

  def get_amount_available(asset, type)
    asset = asset.to_s
    @easy.accounts do |resp|
      resp.each do |account|
        if account.currency == asset
          amount = account.balance
          type == :crypto ? amount = amount.to_f : amount = amount.to_i
          if (type == :crypto && amount < 0.01)
            amount = nil
          elsif (type == :fiat && amount < 10)
            amount = nil
          end

          return amount
        end

      end
    end
  end

  def sig(_time,_method,path,body)
    Base64.encode64(
        OpenSSL::HMAC.digest('sha256', Base64.decode64(@api_secret).strip,
                             "#{_time}#{_method}#{path}#{body}")).strip
  end


  def post(order, minutes, price_change)
  @lock.synchronize {
    if $trade_executed != false then exit end

    apple = get_time_text
    if order == "buy"
      text = "Bought: #{minutes} minute ___ #{price_change}% ___ @#{apple}"
    elsif order == "sell"
      text = "Sold: #{minutes} minute ___ #{price_change}%  ___ @#{apple}"
    end

    trade_executed(minutes, text)

    asset, type = nil
    (order == "sell") ? asset = @crypto : asset = @fiat
    (order == "sell") ? type = :crypto : type = :fiat

    amount = get_amount_available(asset, type)

    req_data = {
        "product_id"=>@product_id,
        "side" => order,
        "type" => "market"
    }

    if (order == "buy")
      req_data["funds"] = amount.to_s
    elsif (order == "sell")
      req_data["size"] = amount.to_s
    end


    path = '/orders'
    _method = 'POST'
    _time = get_time.to_s
    body = req_data.to_json
    signature = sig(_time, _method, path, body )
    req_headers = Net::HTTP::Post.new(path)
    req_headers.body = body
    req_headers['Content-Type'] = 'application/json'
    req_headers['CB-ACCESS-TIMESTAMP'] = _time
    req_headers['CB-ACCESS-PASSPHRASE'] = @api_pass
    req_headers['CB-ACCESS-KEY'] = @api_key
    req_headers['CB-ACCESS-SIGN'] = signature

    @exchange_url = URI.parse(@exchange_url)

    @conn = Net::HTTP.new(@exchange_url.host, @exchange_url.port)
    @conn.use_ssl = true if @exchange_url.scheme == 'https'
    @conn.ssl_version = :TLSv1

    begin
      resp = @conn.request(req_headers)
    rescue StandardError
      p log = "error: #{StandardError}"
      append(log)
    end

          $threads.each do |thread|
            next if thread == Thread.current
            thread.kill
            thread.join
          end
          $trade_executed = true
        }
  end



  def check_change(minutes=60, change=0.8)

    oldPrice = get_spot_price
    sleep(60 * minutes)
    newPrice = get_spot_price
    price_change = (1 - oldPrice.to_f / newPrice.to_f) * 100
    price_change_round = price_change.round(5)

    this_change = change
    if $trend <= -3 or $trend >= 3 then this_change = (change + 0.3) end

    if price_change > this_change
      post("buy", minutes, price_change_round)
    elsif price_change < -this_change
      post("sell", minutes, price_change_round)
    else
      if $trade_executed != false then exit end
      text = "For #{minutes} minute interval there was no trade & Price Change was #{price_change_round}%"
      p text
      check_change(minutes, change)
    end

  end

  def create_request(endpoint, type)
    if type == :exchange then
      return @exchange_url.to_s + endpoint.to_s
    elsif type == :wallet then
      return @wallet_url.to_s + endpoint.to_s
    else
      puts "Failed Request"
      exit
    end
  end

  def get_spot_price
  @lock.synchronize {
    endpoint = "/v2/prices/#{@product_id}/buy"
    uri = create_request(endpoint, :wallet)
    uri = URI(uri)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data["data"]["amount"]
  }
  end

  def get_time
    endpoint = "/time"
    uri = create_request(endpoint, :exchange)
    uri = URI(uri)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data["epoch"]
  end

  def get_time_text
    endpoint = "/time"
    uri = create_request(endpoint, :exchange)
    uri = URI(uri)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data["iso"]
  end



  def append(text)
        p text
        open(@log_file, 'a') do |f|
           f.puts text
           f.close
        end
  end

  def trade_executed(minutes, text, order)
      append(text)
      Nexmo_.new.sms_trade #add the _ to not clash with nexmo class
      $trade_executed = minutes
      if order == "buy" then
        $trend += 1 unless $trend >= 3
      elsif order == "sell" then
        $trend -= 1 unless $trend <= -3
      end
  end

 end #class END
