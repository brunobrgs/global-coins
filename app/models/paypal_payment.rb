require 'paypal-sdk-rest'

class PaypalPayment
  include PayPal::SDK::REST

  def self.call(transaction, options = {})
    cancel_url = options.delete(:cancel_url) || 'http://www.cookpad.com?cancel=true'
    return_url = options.delete(:return_url)

    amount = transaction.amount
    return false if amount <= 0

    coin_price = 0.1
    total_price = coin_price * amount

    payment = Payment.new(
      {
        intent: 'sale',
        payer: { payment_method: 'paypal' },
        redirect_urls: {
          return_url: return_url,
          cancel_url: cancel_url
        },
        transactions: [
          {
            item_list: {
              items: [
                {
                  name: transaction.id,
                  sku: transaction.user.name,
                  price: coin_price,
                  currency: 'GBP',
                  quantity: amount
                }
              ]
            },
            amount: {
              total: total_price,
              currency: 'GBP'
            },
            description: 'Coin transfer'
          }
        ]
      }
    )

    if payment.create
      approval_url = payment.links.find{ |v| v.rel == 'approval_url' }.href
      transaction.update_columns(payment_id: payment.id, approval_url: approval_url)
    else
      transaction.update_attributes(status: "failed")
    end

    payment
  end
end
