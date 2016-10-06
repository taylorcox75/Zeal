class Messenger
  FACEBOOK_PAGE_ACCESS_TOKEN = "EAAZAWPnkEQSsBAEUWcLGQbOX0p80br14CXyddWdKhvKe52wWSDzpHZB0q3bbKcuvNxDiYpOfwcMDN7yGks8ZCr1WPc9wZBlVRATf3FZAdb566RvLTR85AFnsOxQ7rf8CDwStaL9yZCP8uSKGEXZASLfvkiZCmpxHycoK8OoVCZCz8eQZDZD"
  WIT_ACCESS_TOKEN = "6NMGP4FDQ3COQMVYIV5NEHGQTLDUNRJF"
  def self.incoming(params)
    facebook_user_id = params["entry"][0]["messaging"][0]["sender"]["id"] # user id of sender
    message = params["entry"][0]["messaging"][0]["message"] # message contents
    messageCounter = 0
    greeting=0
    responded = "no" #flag to see if we've responded yet to the hello request

     wit_response = Messenger.wit(message["text"])
     print(wit_response)
     #check if the wit response was a "remind" intent
     if !wit_response["entities"]["intent"].nil? && wit_response["entities"]["intent"][0]["value"] == "remind" 
       #gets info about the reminder
       intent = wit_response["entities"]["intent"][0]["value"]
       task = wit_response["entities"]["agenda_entry"][0]["value"]
       taskDay = wit_response["entities"]["datetime"][0]["value"]
     elsif !wit_response["entities"]["Greetings"][0].nil?
      greeting = 1
     end

     print greeting
     print responded
    if greeting==1 && responded=="no"
      replyString = "Hey thanks for using Zeal, I'm a reminder bot'."
      Messenger.reply(replyString,messageCounter,facebook_user_id)
      replyString = "Ask me to remind you about something"
      Messenger.reply(replyString,messageCounter,facebook_user_id)
      responded="yes"
    end

    # check if incoming webhook contains a message
    if !message.nil? && !message["text"].nil?
      # call reply() method
      replyString = "Okay, I will remind you to " + task + " on " + taskDay
      Messenger.reply(replyString,messageCounter,facebook_user_id)
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

  # call the send_message method
  def self.reply(text,messageCounter,facebook_user_id)
    begin
      messageCounter+=1
      return Messenger.send_message({
        # set recipient as the sender of the original message
        "recipient" => {
          "id"=> facebook_user_id
        },
        # set the message contents as the incoming message text
        "message"=>{
          "text"=> text
        }
      })
    end
  end
end

