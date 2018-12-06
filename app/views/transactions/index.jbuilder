json.array! @transactions do |transaction|
  json.amount transaction.amount
  json.details transaction.details
  json.description transaction.description
end
