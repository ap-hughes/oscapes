class AddImageGalleryToRoute < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :image_gallery_1, :string
  end
end
