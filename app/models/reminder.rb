class Reminder < ApplicationRecord
	after_create :remind
	# set reminder to run at a later date
	def remind
		Messenger.delay(run_at: self.dueDate).reply("Reminder to " + self.query, 0, self.facebook_user_id)
	end
end
