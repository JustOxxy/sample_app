require 'test_helper'

class PasswordResetsTests < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    ActionMailer::Base.deliveries.clear
    user = users(:oxxy)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template "password_resets/new"
    # Неверный адрес электронной почты
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template "password_resets/new"
    # Верный адрес электронной почты
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload_reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Форма сброса пароля
    user = assigns(:user)
    # Неверный адрес электронной почты
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Неактивированная учетная запись
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Верный адрес электронной почты, неверный токен
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Верный адрес электронной почты, верный токен
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name = email][type = hidden][value = ?]", user.email
    # Недопустимый пароль и подтверждение
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: "foobaz",
                            password_confirmation: "qwerty" } }
    assert_select 'div#error_explanation'
    # Пустой пароль
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: " ",
                            password_confirmation: " " } }
    assert_not flash.empty?
    assert_template 'password_resets/edit'
    # Допустимый пароль и подтвержение
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user

  end
end
