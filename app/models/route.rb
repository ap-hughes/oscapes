class Route < ApplicationRecord
  belongs_to :user
  has_many :reviews
  has_many :favourites, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  include PgSearch
  pg_search_scope :search_by_route_attributes,
    against: [ :name, :description, :difficulty, :duration, :ascent, :distance ],
    using: {
      tsearch: { prefix: true }
    }
end
