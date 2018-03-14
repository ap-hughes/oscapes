class Route < ApplicationRecord
  belongs_to :user
  has_many :reviews
  has_many :favourites, dependent: :destroy
  has_many :interest_points

  validates :name, presence: true
  validates :description, presence: true

  include PgSearch
  pg_search_scope :search_by_route_attributes,
    against: [ :name, :description, :duration, :ascent, :distance ],
    using: {
      tsearch: { prefix: true }
    }

end
