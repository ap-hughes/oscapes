class RoutesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @routes = policy_scope(Route).order(created_at: :desc)
  end

  def show
    @route = Route.find(params[:id])
    authorize @route
    if @route.difficulty == "Hard"
      @difficulty = 4
    elsif @route.difficulty == "Medium"
      @difficulty = 3
    elsif @route.difficulty == "Low"
      @difficulty = 2
    else
      @difficulty = 1
    end
    @images = get_images(@route)
    @coordinates = @route.coordinates.map { |coordinate| [coordinate.longitude, coordinate.latitude] }
    @center = find_center(@route)
  end

  private

  def get_images(route)
    image_gallery = []
    route.coordinates.each do |coordinate|
      search_terms = {
        lat: coordinate.latitude,
        lon: coordinate.longitude,
        radius: 0,
        has_geo: true,
        content_type: 1,
        # geo_context: 2,
        per_page: 10,
      }

      FlickRaw.api_key = ENV['flickr_api_key']
      FlickRaw.shared_secret = ENV['flickr_api_secret']


      list = flickr.photos.search(search_terms)
      image = FlickRaw.url_c(list[0])
      if image != image_gallery.last
        image_gallery << image
      end
    end
    return image_gallery
  end

  def find_center(route)
    middle = route.coordinates.length / 2
    [route.coordinates[middle].longitude, route.coordinates[middle].latitude]
  end
end
