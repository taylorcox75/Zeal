class Messenger
  FACEBOOK_PAGE_ACCESS_TOKEN = ENV['FACEBOOK_ACCESS_TOKEN']
  WIT_ACCESS_TOKEN = "6NMGP4FDQ3COQMVYIV5NEHGQTLDUNRJF"
  def self.incoming(params)
    facebook_user_id = params["entry"][0]["messaging"][0]["sender"]["id"] # user id of sender
    
    messageCounter = 0
    greeting=0
    responded = "no" #flag to see if we've responded yet to the hello request
    hasTask=false
    hasTaskDay=false

     
     #check if the wit response was a "remind" intent
     if !params["entry"][0]["messaging"].nil? && !params["entry"][0]["messaging"][0]["message"].nil? && !params["entry"][0]["messaging"][0]["message"]["text"].nil?
      message = params["entry"][0]["messaging"][0]["message"]
      wit_response = Messenger.wit(message["text"])
      print(wit_response)
       if !wit_response["entities"].nil? && !wit_response["entities"]["intent"].nil?
         if !wit_response["entities"]["intent"].nil? && wit_response["entities"]["intent"][0]["value"] == "remind" 
           #gets info about the reminder
           intent = wit_response["entities"]["intent"][0]["value"]
           
           if !wit_response["entities"]["agenda_entry"].nil?
            task = wit_response["entities"]["agenda_entry"][0]["value"]
            hasTask = true
           end

         if !wit_response["entities"]["datetime"].nil?
           taskDay = wit_response["entities"]["datetime"][0]["value"]
           hasTaskDay = true
          end
        end
      end

      if !wit_response["entities"].nil? && !wit_response["entities"]["Greetings"].nil?
          if !wit_response["entities"]["Greetings"][0].nil?
          greeting = 1
          end
      end
    end

    if greeting==1 && responded=="no"
      replyString = "Hey, thanks for using Zeal, I'm a reminder bot!"
      Messenger.reply(replyString,messageCounter,facebook_user_id)
      replyString = "Ask me to remind you about something"
      Messenger.reply(replyString,messageCounter,facebook_user_id)
      responded="yes"
      return true
    end

    # check if incoming webhook contains a message
    # have a task with date, create reminder

    if !hasTask || !hasTaskDay
      replyString = "Sorry we dont understand what you wrote, please try again"
      Messenger.reply(replyString,messageCounter,facebook_user_id)
      return true
    end
    if !message.nil? && !message["text"].nil? && !task.nil? && !taskDay.nil? && hasTask && hasTaskDay
      # call reply() method
      date_parsed = DateTime.parse(taskDay)
      reminder = Reminder.create(query: task, facebook_user_id: facebook_user_id, dueDate: date_parsed)
      if reminder
        replyString = "Okay, I will remind you to " + task + " on " + date_parsed.strftime("%A, %B #{date_parsed.day.ordinalize}, %Y at %l:%M %p")
        Messenger.reply(replyString,messageCounter,facebook_user_id)
      end
      return true
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
        "sender_action":"typing_on"
        "recipient" => {
          "id"=> facebook_user_id
        },
        # set the message contents as the incoming message text
        "message"=>{
          "text"=> text
        }
        "sender_action":"typing_off"
      })
    end
  end
end


