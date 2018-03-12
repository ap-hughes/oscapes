class RoutesController < ApplicationController
  require 'nokogiri'

  skip_before_action :authenticate_user!
  before_action :find_route, only: [:show, :edit, :update]
  def index
    if params[:query].present?
      # sql_query = "
      # routes.name @@ :query \
      # OR routes.description @@ :query \
      # "
      @query = params[:query]
      search = Route.search_by_route_attributes("%#{params[:query]}%")
      @routes = policy_scope(search).order(created_at: :desc)
      # .where(sql_query, query: "%#{params[:query]}%")
    else
      @routes = policy_scope(Route).order(created_at: :desc)
    end
  end

  def show
    authorize @route
    @review = Review.new
    @difficulty = get_difficulty_level
    # @coordinates = @route.coordinates.order(id: :desc).map { |coordinate| [coordinate.longitude, coordinate.latitude] }
    @coordinates = coordinates_from(@route.coordinates)
    @interest_points = @route.interest_points #array of interest point instances
    @image_coordinates = get_image_coordinates(@coordinates)
    @center = find_center(@coordinates)
    if !@route.image_gallery_1
      get_images(@image_coordinates)
    end
    @images = [@route.hero_image, @route.image_gallery_1, @route.image_gallery_2]
  end

  def edit
    authorize @route
    @coordinates = coordinates_from(@route.coordinates)
    @image_coordinates = get_image_coordinates(@coordinates)
  end

  def update
    @route.update(route_params)
    redirect_to route_path(@route)
  end

  def get_image
    @route = Route.find(params[:id])
    authorize @route
    @coordinates = coordinates_from(@route.coordinates)
    @image_coordinates = get_image_coordinates(@coordinates)
    search_terms = {
      lat: @image_coordinates[0][1],
      lon: @image_coordinates[0][0],
      radius: 0,
      has_geo: true,
      content_type: 1,
      tags: ['nature', 'landscape'],
      tag_mode: 'any',
      per_page: 10,
    }

    FlickRaw.api_key = ENV['flickr_api_key']
    FlickRaw.shared_secret = ENV['flickr_api_secret']

    list = flickr.photos.search(search_terms)
    number = (0..9).to_a.sample
    @image = FlickRaw.url_c(list[number])
  end

  def new
    @route = Route.new
    authorize @route
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    authorize @route
    file_data = params[:route][:coordinates]
    file_data = File.read(params[:route][:upload].tempfile)
    # if file_data.respond_to?(:read)
    #   xml_contents = file_data.read
    # elsif file_data.respond_to?(:path)
    #   xml_contents = File.read(file_data.path)
    # else
    #   logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    # end
    doc = Nokogiri::XML(file_data)
    trackpoints = doc.xpath('//xmlns:trkpt')
    points = Array.new
    trackpoints.each do |trkpt|
      points << [trkpt.xpath('@lon').to_s.to_f, trkpt.xpath('@lat').to_s.to_f].to_s
    end
    join_array = points.join(",")
    @route.coordinates = join_array.prepend("[") + "]"
    if @route.save
      redirect_to route_path(@route)
    else
      render :new
    end
  end

  private

  def find_route
    @route = Route.find(params[:id])
  end

  def route_params
    params.require(:route).permit(:user_id, :name, :description, :coordinates, :hero_image, :image_gallery_1, :image_gallery_2)
  end

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

  def get_image_coordinates(coordinates)
    if @route.coordinates.start_with?("[[[")
      array_number = coordinates.length / 2
      middle_coordinate = coordinates[array_number].length / 2
      @image_coordinates = [coordinates.first.first, coordinates[array_number][middle_coordinate], coordinates.last.last]
    else
      middle_coordinate = coordinates.length / 2
      @image_coordinates = [coordinates.first, coordinates[middle_coordinate], coordinates.last]
    end
  end

  def get_images(image_coordinates)
    image_gallery = []

    image_coordinates.each do |coordinate|
      search_terms = {
        lat: coordinate[1],
        lon: coordinate[0],
        radius: 0,
        has_geo: true,
        content_type: 1,
        tags: ['nature', 'landscape'],
        tag_mode: 'any',
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
