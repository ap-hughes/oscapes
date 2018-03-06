class RoutesController < ApplicationController
  skip_before_action :authenticate_user!
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
    @coordinates = @route.coordinates.map { |coordinate| [coordinate.longitude, coordinate.latitude] }
    @center = find_center(@route)
  end

  private

  def find_center(route)
    middle = route.coordinates.length / 2
    [route.coordinates[middle].longitude, route.coordinates[middle].latitude]
  end
end
