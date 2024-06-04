class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :check_logged_in
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def check_logged_in
    return if current_user
    flash[:error] = 'ログインしてください'
    redirect_to root_path
  end

  private

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
