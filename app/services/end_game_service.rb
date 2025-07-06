class EndGameService
  def initialize(room)
    @room = room
  end

  def perform
    winner = determine_winner
    distribute_pot(winner)

    {
      winner: {
        player_id: winner.id,
        hand: hand_strength(all_cards(winner)).rank,
      },
      pot: current_game.pot,
    }
  end

  private

  def determine_winner
    players.max_by { |player| hand_strength(all_cards(player)).score[0][0] }
  end

  def distribute_pot(winner)
    winner.receive_pot(current_game.pot)
  end

  def current_game
    @room.current_game
  end

  def players
    current_game.initial_state['players'].map{ |player_data|
      Player.find(player_data['id'])
    }
  end

  def player_cards(player)
    current_game.initial_state['players'].find { |p| p['id'] == player.id }['cards']
  end

  def community_cards
    current_game.game_phases.pluck(:community_cards).reject(&:empty?).flatten
  end

  def all_cards(player)
    player_cards(player) + community_cards
  end

  def hand_strength(all_cards)
    normalized_cards = all_cards.map { |card| card.gsub(/^10/, 'T') }
    PokerHand.new(normalized_cards)
  end
end