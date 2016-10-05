class MessengerController < ApplicationController
  skip_before_action :verify_authenticity_token
  def incoming
  if params["hub.mode"] == "subscribe"
      render :json => params["hub.challenge"], :status => :ok
  else
      Messenger.incoming(params)
      render :json => {}, :status => :ok
  end
end
end