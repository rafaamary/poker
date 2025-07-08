class PlayerGameActionService
  attr_accessor :player, :action, :amount, :room, :game_action

  def initialize(room, player, action, amount = nil)
    @player = player
    @action = action
    @amount = amount
    @room = room
  end

  def perform
    validate!

    ActiveRecord::Base.transaction do
      game_action = create_game_action
      update_game_pot
      update_player_chips
      update_current_player

      {
        current_turn: game_action.current_turn,
        pot: current_game.pot
    }.with_indifferent_access
    end
  rescue StandardError => e
    Rails.logger.error("Error performing game action: #{e.message}")

    raise e
  end

  private

  def validate!
    raise ArgumentError, "Jogador não está na sala" unless room.players.include?(player)
    raise ArgumentError, "Ação inválida" unless %w[check call raise fold].include?(action)
    raise ArgumentError, "Ação não permitida no estado atual: #{action}" unless valid_action?
    raise ArgumentError, "Insufficient chips" if player.chips < amount.to_i && [ "raise", "call" ].include?(action)
    raise StandardError, "Não é sua vez de jogar" unless current_game.initial_state["current_player"] == player.id


    if action == "raise"
      raise ArgumentError, "A aposta deve ser maior que a maior aposta atual: #{biggest_bet}" if amount.to_i <= biggest_bet
    end

    if action == "call"
      raise ArgumentError, "O valor do call deve ser exatamente igual à maior aposta atual: #{biggest_bet}" if amount.to_i != biggest_bet
    end

    if action == "check" && biggest_bet != 0
      raise ArgumentError, "Não é possível dar check se houver uma aposta ativa"
    end
  end

  def current_game
    room.reload.current_game
  end

  def current_game_phase
    current_game.game_phases.last
  end

  def biggest_bet
    current_game_phase.biggest_bet
  end

  def create_game_action
    GameAction.create!(
      player: Player.find(player.id),
      action: action,
      amount: amount,
      game_phase:  GamePhase.find(current_game_phase.id),
    )
  end

  def update_player_chips
    return if action == "check" || action == "fold"

    player.update!(chips: player.chips - amount.to_i || 0)
  end

  def valid_action?
    case @action
    when "check"
      current_game_phase.can_check?
    when "call"
      current_game_phase.can_call?
    when "raise", "fold"
      true
    end
  end

  def update_game_pot
    return if action == "check" || action == "fold"

    amount = @amount.to_i

    current_game.update!(pot: current_game.pot + amount)
  end

  def update_current_player
    current_game.initial_state["current_player"] = current_game.next_player!
    current_game.save!
  end
end
