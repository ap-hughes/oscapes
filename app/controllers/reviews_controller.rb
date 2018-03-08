class ReviewsController < ApplicationController
  def create
    @route = Route.find(params[:route_id])
    @review = Review.new(review_params)
    authorize @review
    @review.route = @route
    @review.user = current_user
    if @review.save
      respond_to do |format|
        format.html { redirect_to route_path(@route) }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'reviews/show' }
        format.js
      end
    end
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
