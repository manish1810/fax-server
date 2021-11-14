class RevenuecatService
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'date'

  def initialize(user_id)
    @user_id = user_id
  end
  
  def subscribed?
    url = URI("https://api.revenuecat.com/v1/subscribers/#{@user_id}")
    
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(url)
    request["Accept"] = 'application/json'
    request["X-Platform"] = 'ios'
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Bearer #{Rails.application.credentials.dig :revenuecat, :api_key}"
    
    response = JSON.parse http.request(request).read_body
    subscription = response["subscriber"]["entitlements"]["Pro subscription"]
    date = DateTime.parse(subscription["expires_date"])
    
    date.future?
  end

end