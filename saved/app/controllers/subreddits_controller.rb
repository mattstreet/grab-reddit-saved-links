class SubredditsController < ApplicationController
  # GET /subreddits
  # GET /subreddits.json
  def index
    @subreddits = Subreddit.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subreddits }
    end
  end

  # GET /subreddits/1
  # GET /subreddits/1.json
  def show
    @subreddit = Subreddit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subreddit }
    end
  end

  # GET /subreddits/new
  # GET /subreddits/new.json
  def new
    @subreddit = Subreddit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subreddit }
    end
  end

  # GET /subreddits/1/edit
  def edit
    @subreddit = Subreddit.find(params[:id])
  end

  # POST /subreddits
  # POST /subreddits.json
  def create
    @subreddit = Subreddit.new(params[:subreddit])

    respond_to do |format|
      if @subreddit.save
        format.html { redirect_to @subreddit, notice: 'Subreddit was successfully created.' }
        format.json { render json: @subreddit, status: :created, location: @subreddit }
      else
        format.html { render action: "new" }
        format.json { render json: @subreddit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subreddits/1
  # PUT /subreddits/1.json
  def update
    @subreddit = Subreddit.find(params[:id])

    respond_to do |format|
      if @subreddit.update_attributes(params[:subreddit])
        format.html { redirect_to @subreddit, notice: 'Subreddit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subreddit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subreddits/1
  # DELETE /subreddits/1.json
  def destroy
    @subreddit = Subreddit.find(params[:id])
    @subreddit.destroy

    respond_to do |format|
      format.html { redirect_to subreddits_url }
      format.json { head :no_content }
    end
  end
end
