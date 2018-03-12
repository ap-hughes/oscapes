class RoutePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def edit?
    update?
  end

  def update?
    # record.user_id == user
    true
  end

  def get_image?
    update?
  end

  def create?
    true
  end

  def download_gpx?
    true
  end

  def set_ascent_and_distance?
    true
  end
end
