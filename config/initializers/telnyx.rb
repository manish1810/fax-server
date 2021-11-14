require 'telnyx'

Telnyx.api_key = Rails.application.credentials.dig :telnyx, :api_key