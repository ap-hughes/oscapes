class AddHeroImageToRoute < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :hero_image, :string, default: "https://images.unsplash.com/photo-1467294388771-b3e867a4d321?ixlib=rb-0.3.5&s=914592383364aed60abbfaf7b74d9ad4&auto=format&fit=crop&w=1050&q=80"
  end
end
