class AddImageGallery2ToRoute < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :image_gallery_2, :string
  end
end
