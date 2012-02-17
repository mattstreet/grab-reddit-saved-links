class CreateSubreddits < ActiveRecord::Migration
  def change
    create_table :subreddits do |t|
      t.string :name
      t.string :subreddit_id

      t.timestamps
    end
  end
end
