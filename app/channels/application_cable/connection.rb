module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_verified_player
    end

    private

    def find_verified_player
      # Allow connection without immediate authentication
      # Authentication will be handled at the channel level
      if player_id = request.params[:player_id]
        begin
          Player.find(player_id)
        rescue ActiveRecord::RecordNotFound
          nil
        end
      else
        # Return a placeholder for unauthenticated connections
        nil
      end
    end
  end
end
