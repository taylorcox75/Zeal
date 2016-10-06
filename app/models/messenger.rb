class Messenger
  FACEBOOK_PAGE_ACCESS_TOKEN = "EAAZAWPnkEQSsBAEUWcLGQbOX0p80br14CXyddWdKhvKe52wWSDzpHZB0q3bbKcuvNxDiYpOfwcMDN7yGks8ZCr1WPc9wZBlVRATf3FZAdb566RvLTR85AFnsOxQ7rf8CDwStaL9yZCP8uSKGEXZASLfvkiZCmpxHycoK8OoVCZCz8eQZDZD"
  WIT_ACCESS_TOKEN = "6NMGP4FDQ3COQMVYIV5NEHGQTLDUNRJF"

  def self.incoming(params)
    facebook_user_id = params["entry"][0]["messaging"][0]["sender"]["id"] # user id of sender
    message = params["entry"][0]["messaging"][0]["message"] # message contents



     wit_response = Messenger.wit(message["text"])
     print(wit_response)
     #check if the wit response was a "remind" intent
     if wit_response["entities"]["intent"][0]["value"] == "remind"
       #return the value of the stock symbol
       task = wit_response["entities"]["intent"][0]["value"]
       taskDay = wit_response["entities"]["datetime"]["body"]["value"]
       print(task)
       print(taskDay)
     end

    # check if incoming webhook contains a message
    if !message.nil? && !message["text"].nil?
      # call send_message() method
      return Messenger.send_message({
        # set recipient as the sender of the original message
        "recipient" => {
          "id"=> facebook_user_id
        },
        # set the message contents as the incoming message text
        "message"=>{
          "text"=> message["text"]
        }
      })
    end
  end

  # request Wit API
  def self.wit(text)
    begin
      wit = Nestful::Request.new(URI.encode("https://api.wit.ai/message?q=#{text}"), method: :get, auth_type: :bearer, password: WIT_ACCESS_TOKEN).execute
      wit = wit.body
      return JSON.parse(wit)
    rescue => e
      return e
    end
  end

  # send message via Messenger Send API
  def self.send_message(payload)
    begin
      response = RestClient.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{FACEBOOK_PAGE_ACCESS_TOKEN}", payload.to_json, :content_type => :json, :accept => :json
    rescue => e
      return e
    end
  end
end