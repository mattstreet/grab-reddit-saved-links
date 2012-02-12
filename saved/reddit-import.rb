#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'active_record'
require 'yaml'
require 'mechanize'
require 'json'
require 'pp'

# Add CLI option and default
dbconfig = YAML::load(File.open('config/database.yml'))

# Add CLI and default
ActiveRecord::Base.establish_connection(dbconfig["development"])

# Is this the best way to do this?
class Post < ActiveRecord::Base
end

# How to iterate through and access each post
# Post.all.each do |post|
#   puts post.url
# end

# This needs to be a Thor task so it doesn't auto run
# Make it loop through every page, with a default option to stop 
# once it gets to a link it has read before.
def login
  agent = Mechanize.new
  agent.get('http://reddit.com') do |login_page|
      inside_page = login_page.form_with(:id => 'login_login-main') do |f|
          f.user = "mattstreet" # Needs CLI option
          f.passwd = "JV!5vUV#Jn$QvbNS" # Needs CLI option and something more secure
          f.submit
      end
  end
  return agent
end

class App < Thor

  desc "import", "download links saved on reddit"
  method_option :password, :type => :string, :aliases => "-p"
  def import
    puts "Password",options[:password]
    exit
    agent = login
    after = ""
    last = ""
    while true do
      page = agent.get("http://reddit.com/saved.json#{after}")

      page = JSON.parse(page.content)
      page['data']['children'].each do |link|
        data = link['data']
        if !Post.where(:name => data['name'],
                      :created_utc => data['created_utc']).empty? then
          puts "Reached old links"
          exit
        end
        post = Post.create do |p|
          p.title              = data['title']
          p.name               = data['name']
          p.subreddit          = data['subreddit']
          p.selftext_html      = data['selftext_html']
          p.selftext           = data['selftext']
          p.author             = data['author']
          p.permalink          = data['permalink']
          p.url                = data['url']
          p.domain             = data['domain']
          p.created_utc        = data['created_utc']
          p.num_comments       = data['num_comments']
          p.likes              = data['likes']
          p.score              = data['score']
          p.ups                = data['ups']
          p.downs              = data['downs']
          p.over_18            = data['over_18']
          p.is_self            = data['is_self']
        end
        # pp post.title
      end
      if page['data']['after'].nil? then 
        puts page['data']['after']
        break 
      end
      last = page['data']['after']
      after = "?after=#{last}"
      pp last
      sleep(5)
    end
  end
end
# Create task that accesses an already created database and
# exports information

# Options: 
# JSON (could warn about memory usage)
# HTML verbose or short
# Bookmarks format
# Filter by subreddits
# Filter by domain
# Filter by author
# Filter by score,comments, over_18
# Create only one file or multiple?
# Delete by filter or delete all but filter

App.start
