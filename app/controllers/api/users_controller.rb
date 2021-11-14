class Api::UsersController < ApplicationController
  before_action :authorized?, only: [:auto_login]

  # Register
  def create
    @user = User.create(user_params)
    if @user.valid?
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }
    else
      render json: { error: "Invalid record ID or user already registered" }, status: :bad_request
    end
  end

  def login
    @user = User.find_by_record_id(params[:record_id])

    if @user
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }
    else
      render json: { error: "Invalid record ID" }, status: :not_found
    end
  end

  private
  
  def user_params
    params.permit(:record_id)
  end
end
