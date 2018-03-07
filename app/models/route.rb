class Route < ApplicationRecord
  belongs_to :user
  has_many :reviews
  has_many :favourites

  validates :name, presence: true
  validates :description, presence: true
end
