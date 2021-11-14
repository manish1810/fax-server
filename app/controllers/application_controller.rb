class ApplicationController < ActionController::API
  before_action :authorized?

  def encode_token(payload)
    JWT.encode payload, Rails.application.secrets.secret_key_base.to_s, 'HS256'
  end
  
  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end
  
  def logged_in_user
    return unless auth_header

    token = auth_header.split(' ')[1]
    # header: { 'Authorization': 'Bearer <token>' }
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s, true, algorithm: 'HS256')
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { errors: 'Expired token' }, status: :unauthorized
    end
  end
  
  def current_user
    logged_in_user
  end
  
  def logged_in?
    !!logged_in_user
  end
  
  def authorized?
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
