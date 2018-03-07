class AddCoordinatesToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :coordinates, :string
  end
end
