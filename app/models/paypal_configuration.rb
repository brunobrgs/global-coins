require 'paypal-sdk-rest'

module PaypalConfiguration
  include PayPal::SDK::REST

  def set_paypal_config
    PayPal::SDK::REST.set_config(
      mode: ENV['PAYPAL_MODE'],
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET']
    )
  end
end
