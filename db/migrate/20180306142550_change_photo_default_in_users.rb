class ChangePhotoDefaultInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :photo, "default-profile"
  end
end
