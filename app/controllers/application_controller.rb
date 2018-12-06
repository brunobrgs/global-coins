class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  def errors(object)
    object.errors.full_messages
  end
end
