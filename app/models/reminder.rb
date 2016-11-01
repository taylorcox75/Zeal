class Reminder < ApplicationRecord
	after_create :remind
	# set reminder to run at a later date
	def remind
		self.delay(run_at: self.dueDate).send_reminder
	end

	def send_reminder
		buttons = [
			{
				"type" => "postback",
				"title" => "View Reminders",
				"payload" => "VIEW_SCHEDULE_PAYLOAD"
			},
			{
				"type" => "postback",
				"title" => "View Completed",
				"payload" => "VIEW_COMPLETED_PAYLOAD"
			},
		]
		Messenger.replyButtons("Reminder to " + self.query + " ☑️", 0, self.facebook_user_id, buttons)
		self.update_attributes(done: true) # update done attribute to true
	end

	def self.schedule(facebook_user_id)
		self.all.where(facebook_user_id: facebook_user_id).where(done: false).order("dueDate ASC")
	end

	def self.completed(facebook_user_id)
		self.all.where(facebook_user_id: facebook_user_id).where(done: true).order("dueDate ASC")
	end
end
