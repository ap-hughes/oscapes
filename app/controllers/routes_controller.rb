class RoutesController < ApplicationController
  def index

  end

  def show
    @route = Route.find(params[:id])
    if @route.difficulty == "Hard"
      @difficulty = 4
    elsif @route.difficulty == "Medium"
      @difficulty = 3
    elsif @route.difficulty == "Low"
      @difficulty = 2
    else
      @difficulty = 1
    end
  end
end
