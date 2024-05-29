require "test_helper"

class UserAnswersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_answers_new_url
    assert_response :success
  end

  test "should get create" do
    get user_answers_create_url
    assert_response :success
  end

  test "should get edit" do
    get user_answers_edit_url
    assert_response :success
  end

  test "should get update" do
    get user_answers_update_url
    assert_response :success
  end

  test "should get submit" do
    get user_answers_submit_url
    assert_response :success
  end

  test "should get results" do
    get user_answers_results_url
    assert_response :success
  end

  test "should get index" do
    get user_answers_index_url
    assert_response :success
  end

  test "should get show" do
    get user_answers_show_url
    assert_response :success
  end
end
