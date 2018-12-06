require 'paypal-sdk-rest'

PayPal::SDK::REST.set_config(
  mode: ENV['PAYPAL_MODE'],
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET']
)
