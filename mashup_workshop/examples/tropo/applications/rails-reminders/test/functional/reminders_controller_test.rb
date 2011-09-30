require 'test_helper'

class RemindersControllerTest < ActionController::TestCase
  setup do
    @reminder = reminders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reminders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reminder" do
    assert_difference('Reminder.count') do
      post :create, :reminder => @reminder.attributes
    end

    assert_redirected_to reminder_path(assigns(:reminder))
  end

  test "should show reminder" do
    get :show, :id => @reminder.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @reminder.to_param
    assert_response :success
  end

  test "should update reminder" do
    put :update, :id => @reminder.to_param, :reminder => @reminder.attributes
    assert_redirected_to reminder_path(assigns(:reminder))
  end

  test "should destroy reminder" do
    assert_difference('Reminder.count', -1) do
      delete :destroy, :id => @reminder.to_param
    end

    assert_redirected_to reminders_path
  end
end
