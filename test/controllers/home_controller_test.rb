require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # If using devise

  def setup
    prepare_test_data
  end

  test "should get index" do
    get root_path
    assert_response :success
  end

  test "should get view_posts" do
    get root_path
    assert_response :success
  end

  test "should get view_posts with tags" do
    get root_path, params: { tags: "Technology,Science" }
    assert_response :success
  end

  test "should get view_posts with status" do
    get root_path, params: { status: "published" }
    assert_response :success
  end

  test "should match number of posts considering pagination" do
    get root_path
    assert_equal 9, assigns(:posts).size
  end

  def teardown
    # Clean up in reverse order of dependencies
    PostTag.destroy_all
    Post.destroy_all
    Tag.destroy_all
    User.destroy_all
  end
end
