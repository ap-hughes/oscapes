class ReviewsController < ApplicationController
  def create
    @route = Route.find(params[:route_id])
    @user = current_user
    @review = Review.new(review_params)
    authorize @review
    @review.route = @route
    @review.user = @user
    if @review.save
      redirect_to route_path(@route)
    else
      render 'reviews/show'
    end
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
