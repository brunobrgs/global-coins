require 'paypal-sdk-rest'

class PaypalPayout
  include PayPal::SDK::REST

  def self.call(transaction)
    value = transaction.amount / 10

    payout = Payout.new(
      {
        :sender_batch_header => {
          :sender_batch_id => SecureRandom.hex(8),
          :email_subject => 'You redeemed coins from Cookpad!',
        },
        :items => [
          {
            :recipient_type => 'EMAIL',
            :amount => {
              :value => value.abs,
              :currency => 'GBP'
            },
            :note => 'Thanks for your support!',
            :receiver => transaction.email,
            :sender_item_id => transaction.id.to_s,
          }
        ]
      }
    )

    payout_batch = payout.create
    if payout_batch && payout_batch.batch_header.payout_batch_id
      transaction.update_attributes!(
        payout_batch_id: payout_batch.batch_header.payout_batch_id,
        status: "success"
      )
    else
      transaction.update_attributes(status: "failed")
    end

    payout
  end
end
