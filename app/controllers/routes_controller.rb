class RoutesController < ApplicationController
  require 'nokogiri'
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :find_route, only: [:show, :edit, :update]
  def index
    # if params[:query].present?
    #   # sql_query = "
    #   # routes.name @@ :query \
    #   # OR routes.description @@ :query \
    #   # "
    #   @query = params[:query]
    #   search = Route.search_by_route_attributes("%#{params[:query]}%")
    #   @routes = policy_scope(search).order(created_at: :desc)
    #   # .where(sql_query, query: "%#{params[:query]}%")
    # else
    #   @routes = policy_scope(Route).order(created_at: :desc)
    #   # starting_coordinates(@routes)
    # end

    if params[:search]
      @difficulty = params[:search]["difficulty"].present? ? params[:search]["difficulty"] : nil
      @difficulty_array = params[:search]["difficulty"].present? ? params[:search]["difficulty"] : ["Challenging", "Moderate", "Easy", nil]
      @distance = params[:search]["distance"].present? ? params[:search]["distance"].split('..') : nil
      @distance_range_array = params[:search]["distance"].present? ? params[:search]["distance"].split('..') : [0,Route.all.collect(&:distance).map(&:to_i).max]
      @ascent = params[:search]["ascent"].present? ? params[:search]["ascent"].split('..') : nil
      @ascent_range_array = params[:search]["ascent"].present? ? params[:search]["ascent"].split('..') : [0,Route.all.collect(&:ascent).map(&:to_i).max]
      @duration = params[:search]["duration"].present? ? params[:search]["duration"].split('..') : nil
      @duration_range_array = params[:search]["duration"].present? ? params[:search]["duration"].split('..') : [0,Route.all.collect(&:duration).map(&:to_i).max]

      search = Route.where(difficulty: @difficulty_array)
              .where('ascent between ? and ? or distance is null', @distance_range_array[0].to_i, @distance_range_array[1].to_i)
              .where('ascent between ? and ? or ascent is null', @ascent_range_array[0].to_i, @ascent_range_array[1].to_i)
              .where('duration between ? and ? or duration is null', @duration_range_array[0].to_i, @duration_range_array[1].to_i)
      @routes = policy_scope(search).order(created_at: :desc)

    else
      @routes = policy_scope(Route).order(created_at: :desc)
    end
    # @difficulty = params[:search]["difficulty"].present? ? params[:search]["difficulty"] : "Difficulty"
    # @distance = params[:search]["distance"].present? ? params[:search]["distance"] : "Distance"
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
    @average_rating = get_average_rating(@route)
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
    lat_long = get_starting_ending_coordinates(@route)
    set_lat_long_attributes(lat_long)
    if @route.save
      @coordinates = coordinates_from(@route.coordinates)
      respond_to do |format|
        format.js { render "create", :locals => {:coordinates => @coordinates} }
      end
      # redirect_to route_path(@route)
    else
      render :new
    end
  end

  def download_gpx
    @route = Route.find(params[:route_id])
    authorize @route
    write_gpx(@route)
  end

  def set_ascent_and_distance
    @route = Route.find(params[:id])
    @route.update(route_params)
    duration = @route.distance / 5 + (@route.ascent / 330) * 0.5
    if duration > 20 && @route.ascent > 2000
      difficulty = "Challenging"
    elsif duration >20 && @route.ascent >1000
      difficulty = "Moderate"
    else
      difficulty = "Easy"
    end
    @route.update(duration: duration, difficulty: difficulty)
    authorize(@route)
    head :no_content
  end

  private

  def find_route
    @route = Route.find(params[:id])
  end

  def route_params
    params.require(:route).permit(:user_id, :name, :description, :coordinates, :hero_image, :image_gallery_1, :image_gallery_2, :distance, :ascent, :duration, :difficulty)
  end

  def get_average_rating(route)
    reviews = route.reviews
    if reviews == []
      average_rating = nil
    else
      ratings = []
      reviews.each do |review|
        ratings << review.rating
      end
      average_rating = "%.1f" % ratings.reduce(:+).fdiv(ratings.length)
    end
    average_rating
  end

  def get_difficulty_level
    if @route.difficulty == "Challenging"
      @difficulty = 4
    elsif @route.difficulty == "Moderate"
      @difficulty = 3
    elsif @route.difficulty == "Easy"
      @difficulty = 2
    else
      @difficulty = 1
    end
  end

    # def starting_coordinates(routes)
  #   @start_coordinates = []
  #   routes.each do |route|
  #     if route.coordinates.start_with?("[[[")
  #       coordinates = coordinates_from(route.coordinates)
  #       first_coordinates = coordinates.first.first
  #       @start_coordinates << first_coordinates
  #     else
  #       coordinates = coordinates_from(route.coordinates)
  #       first_coordinates = coordinates.first
  #       @start_coordinates << first_coordinates
  #     end
  #   end
  #   @start_coordinates
  # end

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
    coordinates = JSON.parse(string)
    coordinates.each do |coordinate|
      coordinate.map { |f| '%.12f' % f }
    end
    coordinates
  end

  #two methods to get and set the starting and ending latitudes and longitudes:
  def get_starting_ending_coordinates(route)
      # if route.coordinates.start_with?("[[[")
      #   coordinates = coordinates_from(route.coordinates)
      #   start_latitude = coordinates.first.first.first
      #   start_longitude = coordinates.first.first.last
      #   end_latitude = coordinates.first.last.first
      #   end_longitude = coordinates.first.last.last
      #   @start_coordinates << first_coordinates
      # else
      #   coordinates = coordinates_from(route.coordinates)
      #   first_coordinates = coordinates.first
      #   @start_coordinates << first_coordinates
      # end
    coordinates = coordinates_from(route.coordinates)
    {
      start_latitude: coordinates.first.first,
      start_longitude: coordinates.first.last,
      end_latitude: coordinates.last.first,
      end_longitude: coordinates.last.last
    }
  end

  def set_lat_long_attributes(lat_long_hash)
    @route.start_latitude = lat_long_hash[:start_latitude]
    @route.start_longitude = lat_long_hash[:start_longitude]
    @route.end_latitude = lat_long_hash[:end_latitude]
    @route.end_longitude = lat_long_hash[:end_longitude]
    @route.save!
  end

  def write_gpx(route)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.gpx(
      :creator              => 'Oscapes',
      :version              => "1.1",
      :xmlns                => "http://www.topografix.com/GPX/1/1",
      'xmlns:xsi'           => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation'  => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
      ) do
        if route.coordinates.start_with?("[[[")
          coordinates = coordinates_from(route.coordinates)
          coordinates.each do |coordinate|
            xml.trk do
              xml.trkseg do
                coordinate.each do |coord|
                  xml.trkpt(:lat => coord[1], :lon => coord[0])
                end
              end
            end
          end
        else
          coordinates = coordinates_from(route.coordinates)
          xml.trk do
            xml.trkseg do
              coordinates.each do |coordinate|
                xml.trkpt(:lat => coordinate[1], :lon => coordinate[0])
              end
            end
          end
        end
      end
    end
    send_data(builder.to_xml, type: 'text/xml; charset=UTF-8;', disposition: 'attachment; filename=route.gpx')
  end

end
