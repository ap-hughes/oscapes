class Route < ApplicationRecord
  belongs_to :user
  has_many :coordinates
end
