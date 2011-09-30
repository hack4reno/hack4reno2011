class ApplicationController < ActionController::Base
  layout 'master'
  helper :all

  def isNumeric(s)
      Float(s) != nil rescue false
  end
end
