class FavouritesController < ApplicationController
  def create
    @route = Route.find(params[:route_id])
    @favourite = Favourite.new
    authorize @favourite
    if current_user.favourites.any? { |favourite| favourite.route_id == @route.id }
      flash[:alert] = "You have already bookmarked this route."
      redirect_to request.referrer
    else
      @favourite.user = current_user
      @favourite.route = @route
      if @favourite.save
        link =
        flash[:notice] = "This post has been bookmarked! You can view all of your bookmarked routes #{view_context.link_to("here", dashboard_path)}".html_safe
        redirect_to request.referrer
      else
        flash[:alert] = "You need to be logged in to your account to bookmark a route."
        redirect_to new_user_session
      end
    end
  end

  def destroy

  end
end
