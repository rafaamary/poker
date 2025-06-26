class RoomSerializer < ActiveModel::Serializer
  attributes :id, :name, :max_players, :current_players
end
