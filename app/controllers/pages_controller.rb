class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @routes = Route.take(3)
  end
end
