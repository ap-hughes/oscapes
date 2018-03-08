class RoutesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @routes = policy_scope(Route).order(created_at: :desc)
  end

  def show
    @route = Route.find(params[:id])
    authorize @route
    @review = Review.new
    @difficulty = get_difficulty_level
    # @coordinates = @route.coordinates.order(id: :desc).map { |coordinate| [coordinate.longitude, coordinate.latitude] }
    @coordinates = coordinates_from(@route.coordinates)
    @center = find_center(@coordinates)
    if !@route.image_gallery_1
      get_images(@coordinates)
    end
    @images = [@route.hero_image, @route.image_gallery_1, @route.image_gallery_2]
  end


  private

  def get_difficulty_level
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

  def get_images(coordinates)
    image_gallery = []
    if @route.coordinates.start_with?("[[[")
      array_number = coordinates.length / 2
      middle_coordinate = coordinates[array_number].length / 2
      image_coordinates = [coordinates.first.first, coordinates[array_number][middle_coordinate], coordinates.last.last]
    else
      middle_coordinate = coordinates.length / 2
      image_coordinates = [coordinates.first, coordinates[middle_coordinate], coordinates.last]
    end

    image_coordinates.each do |coordinate|
      search_terms = {
        lat: coordinate[1],
        lon: coordinate[0],
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
      image_gallery << image
    end
    @route.hero_image = image_gallery[0]
    @route.image_gallery_1 = image_gallery[1]
    @route.image_gallery_2 = image_gallery[2]
    @route.save
    return image_gallery
  end

  def find_center(route)
    if @route.coordinates.start_with?("[[[")
      array_number = route.length / 2
      middle = route[array_number].length / 2
      [route[array_number][middle][0], route[array_number][middle][1]]
    else
      middle = route.length / 2
      [route[middle][0], route[middle][1]]
    end
  end

  def coordinates_from(string)
    # if string.start_with?("/\[\[\[/")
      coordinates = JSON.parse(string)
      coordinates.each do |coordinate|
        coordinate.map { |f| '%.12f' % f }
      end
      coordinates
    # else
    #   array = string.tr("[]", "").split(",")
    #   floats = array.map(&:to_f)
    #   coordinates = []
    #   i = floats.length
    #   x = 0
    #   while x < i
    #     coordinates << floats[x..x+1]
    #     x +=2
    #   end
    #   coordinates
    # end
  end

end
