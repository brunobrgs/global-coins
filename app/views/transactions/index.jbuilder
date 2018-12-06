json.balance @user.balance

json.transactions @transactions do |transaction|
  json.amount transaction.amount
  json.details transaction.details
  json.description transaction.description
  json.recipe_id transaction.recipe_id
  json.destination_user_id transaction.destiny_user.try(:external_id)
end
