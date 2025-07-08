class EndGameService
  attr_reader :room

  def initialize(room)
    @room = room
  end

  def perform
    game = current_game
    winner = determine_winner
    winner_hand = hand_strength(all_cards(winner)).rank
    pot_amount = game.pot

    distribute_pot(winner)
    update_game(game, winner, winner_hand)

    {
      winner: {
        player_id: winner.id,
        hand: winner_hand
      },
      pot: pot_amount
    }
  end

  private

  def update_game(game, winner, winner_hand)
    game.update!(
      finished_at: Time.current,
      initial_state: game.initial_state.merge(
        winner: {
          player_id: winner.id,
          hand: winner_hand
        }
      )
    )
  end

  def determine_winner
    players.max_by { |player| hand_score(player) }
  end

  def distribute_pot(winner)
    winner.receive_pot(current_game.pot)
  end

  def current_game
    @current_game ||= room.current_game
  end

  def players
    @players ||= begin
      player_ids = current_game.initial_state["players"].map { |p| p["id"] }
      Player.where(id: player_ids)
    end
  end

  def player_cards(player)
    current_game.initial_state["players"]
      .find { |p| p["id"] == player.id }["cards"]
  end

  def community_cards
    current_game.initial_state["community_cards"]
  end

  def all_cards(player)
    player_cards(player) + community_cards
  end

  def hand_score(player)
    hand_strength(all_cards(player)).score[0][0]
  end

  def hand_strength(cards)
    normalized = cards.map { |card| card.sub(/^10/, "T") }
    PokerHand.new(normalized)
  end
end
