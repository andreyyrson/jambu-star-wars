require "test_helper"

class FavoritesListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get favorites_lists_index_url
    assert_response :success
  end

  test "should get show" do
    get favorites_lists_show_url
    assert_response :success
  end

  test "should get create" do
    get favorites_lists_create_url
    assert_response :success
  end
end
