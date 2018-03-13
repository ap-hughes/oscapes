class AddStartEndLatLongToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :start_latitude, :float
    add_column :routes, :end_latitude, :float
    add_column :routes, :start_longitude, :float
    add_column :routes, :end_longitude, :float
  end
end
