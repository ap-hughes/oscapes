class AddColumnCommunityLevelToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :community_level, :string, default: "Junior Oscaper"
  end
end
