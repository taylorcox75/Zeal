class CreateReminders < ActiveRecord::Migration[5.0]
  def change
    create_table :reminders do |t|
      t.text :query
      t.string :facebook_user_id
      t.datetime :dueDate
      t.integer :priority
      t.boolean :done

      t.timestamps
    end
  end
end
