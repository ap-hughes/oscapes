class AddLatLongToInterestPoints < ActiveRecord::Migration[5.1]
  def change
    add_column :interest_points, :longitude, :float
    add_column :interest_points, :latitude, :float
  end
end
