require 'test_helper'

class SubredditsControllerTest < ActionController::TestCase
  setup do
    @subreddit = subreddits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subreddits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subreddit" do
    assert_difference('Subreddit.count') do
      post :create, subreddit: @subreddit.attributes
    end

    assert_redirected_to subreddit_path(assigns(:subreddit))
  end

  test "should show subreddit" do
    get :show, id: @subreddit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @subreddit
    assert_response :success
  end

  test "should update subreddit" do
    put :update, id: @subreddit, subreddit: @subreddit.attributes
    assert_redirected_to subreddit_path(assigns(:subreddit))
  end

  test "should destroy subreddit" do
    assert_difference('Subreddit.count', -1) do
      delete :destroy, id: @subreddit
    end

    assert_redirected_to subreddits_path
  end
end
