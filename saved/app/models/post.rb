class Post < ActiveRecord::Base
  acts_as_indexed :fields => [:title, :author,:subreddit,:domain]
end
