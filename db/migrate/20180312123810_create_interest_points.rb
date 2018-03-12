class CreateInterestPoints < ActiveRecord::Migration[5.1]
  def change
    create_table :interest_points do |t|
      t.string :title
      t.string :description
      t.references :route, foreign_key: true
      t.string :longitude
      t.string :latitude

      t.timestamps
    end
  end
end
