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
end
