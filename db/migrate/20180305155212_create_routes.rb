class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.string :name
      t.text :description
      t.string :difficulty
      t.integer :duration
      t.integer :ascent
      t.integer :distance
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
