class UsersController < ApplicationController
  before_action :set_user
  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to user_path(@user) }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'users/form' }
        format.js
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:bio, :favourites, :photo, :ability, :first_name, :last_name)
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
