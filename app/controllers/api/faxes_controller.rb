class Api::FaxesController < ApplicationController
  before_action :authorized?, except: [:webhook]
  before_action :can_send_fax?, only: [:create]
  
  def index
    render json: Fax.where(user: current_user).order(:id)
  end
  
  def show
    @fax = Fax.find_by_id(show_params[:id])
    render json: { error: 'Not found' }, status: :not_found and return unless @fax && @fax.user == current_user
    
    render json: @fax
  end
  
  def create
    create_fax
    
    render json: { errors: @fax.errors.full_messages }, status: :bad_request and return unless @fax.persisted?
    
    disable_send = Rails.env.development?
    render json: @fax and return if disable_send
    
    send_fax
  end

  def webhook
    fax_id = params[:data][:payload][:fax_id]
    return unless fax_id
    
    @fax = Fax.where(service_id: fax_id)[0]
    render json: { error: 'Could not find fax' }, status: :bad_request and return unless @fax
    
    event = webhook_params[:event_type].to_s
    if event == 'fax.delivered'
      @fax.update(status: :delivered)
    elsif event == 'fax.queued'
      @fax.update(status: :queued)
    elsif event == 'fax.media.processed'
      @fax.update(status: :processed)
    elsif event == 'fax.sending.started'
      @fax.update(status: :sending)
    elsif event == 'fax.failed'
      @fax.update(status: :failed)
    end
  end
  
  private
  
  def can_send_fax?
    service = RevenuecatService.new(current_user.record_id)
    can_send = service.subscribed? || current_user.faxes.count == 0
    
    render json: { error: 'Subscription is not active or user has exceeded free usage' }, status: :forbidden and return unless can_send
  end
  
  def create_fax
    @fax = Fax.create(create_params)
    @fax.user = current_user
    @fax.save
  end
  
  def send_fax
    response = Telnyx::Fax.create(
      from: Fax::SENDING_NUMBER,
      to: @fax.phone_number,
      media_url: @fax.file.url,
      connection_id: Rails.application.credentials.dig(:telnyx, :app_id).to_s
    )
    @fax.update(service_id: response[:id].to_s)
  end
  
  def create_params
    params.permit(:phone_number, :file)
  end
  
  def show_params
    params.permit(:id, :file)
  end
  
  def webhook_params
    params.require(:data).permit(:payload, :event_type)
  end
end
