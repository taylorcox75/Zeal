class Reminder < ApplicationRecord
	after_create :set_reminder
	# set reminder to run at a later date
	def set_reminder
		self.delay(run_at: self.dueDate).remind
	end

	# send user message to remind them
	def remind
		Messenger.reply("Reminder to " + self.query, 0, self.facebook_user_id)
	end
end
