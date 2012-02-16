class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user
      t.string :title
      t.string :name
      t.string :selftext_html
      t.string :selftext
      t.string :author
      t.string :subreddit
      t.string :permalink
      t.string :url
      t.string :domain
      t.date :created_utc
      t.integer :num_comments
      t.boolean :likes
      t.integer :ups
      t.integer :downs
      t.integer :score
      t.boolean :over_18
      t.boolean :is_self

      t.timestamps
    end
  end
end
