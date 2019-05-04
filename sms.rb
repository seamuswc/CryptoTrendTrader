require 'nexmo'


class Nexmo_ #Nexmo add _ to not clash with nexmo gem

  def initialize
    @sms_to = "12038100436"
    @sms_from = "12019321351"
    @client = Nexmo::Client.new(
      api_key: "b92104c3",
      api_secret: "wYu0Nce3mFr6JC8Y"
    )
  end


  def sms_trade

    @client.sms.send(
      from: @sms_from,
      to: @sms_to,
      text: 'A trade was made. RubyCoin'
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