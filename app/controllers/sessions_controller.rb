class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create
end
