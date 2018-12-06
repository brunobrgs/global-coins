require 'paypal-sdk-rest'

class PaypalConfirmation
  include PayPal::SDK::REST

  def self.call(params)
    transaction = ::Transaction.find_by(payment_id: params['paymentId'])
    return if transaction.blank?

    payment = Payment.find(transaction.payment_id)
    payment.execute(payer_id: params['PayerID'])
    if payment.state == 'approved'
      ApplicationRecord.transaction do
        transaction.update_attributes!(status: "success")
        user = transaction.user
        user.balance += transaction.amount.abs
        user.save!
      end
    end

    payment
  end
end
