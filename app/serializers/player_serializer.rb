class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :chips

  def chips
    1000
  end
end
