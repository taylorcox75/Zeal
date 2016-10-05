json.extract! reminder, :id, :query, :facebook_user_id, :dueDate, :priority, :done, :created_at, :updated_at
json.url reminder_url(reminder, format: :json)