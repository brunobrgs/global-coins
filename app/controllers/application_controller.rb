class ApplicationController < ActionController::Base
  def errors(object)
    object.errors.full_messages
  end
end
