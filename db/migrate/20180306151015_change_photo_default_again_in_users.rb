class ChangePhotoDefaultAgainInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :photo, "http://res.cloudinary.com/dpu1qidv2/image/upload/v1520266484/default-profile.png"
  end
end
