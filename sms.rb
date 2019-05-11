require 'nexmo'


class Nexmo_ #Nexmo add _ to not clash with nexmo gem

  def initialize
    @sms_to = ""
    @sms_from = ""
    @client = Nexmo::Client.new(
      api_key: "",
      api_secret: ""
    )
  end


  def sms_trade(text)

    @client.sms.send(
      from: @sms_from,
      to: @sms_to,
      text: text
    )

  end

  def sms_start

    @client.sms.send(
      from: @sms_from,
      to: @sms_to,
      text: 'RubyCoin has started'
    )

  end

end #class end
