class RemoveLatLongFromInterestPoints < ActiveRecord::Migration[5.1]
  def change
    remove_column :interest_points, :longitude, :string
    remove_column :interest_points, :latitude, :string
  end
end
