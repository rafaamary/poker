RSpec.describe PlayerGameActionService do
  let(:room) { Room.create!(name: "Test Room", max_players: 4) }
  let(:game) { Game.create!(room: room) }
  let(:player) { Player.create!(name: "Test Player", chips: 1000) }
  let(:game_phase) { GamePhase.create!(game: game, phase: "pre-flop", community_cards: []) }
  let(:game_action) { GameAction.create!(
    player: player,
    game: game,
    action: "check",
    amount: 100,
    game_phase: game_phase
  ) }

  before do
    room.player_join(player)
  end

  describe "#perform" do
    context "validate!" do
      it "player is not in the room" do
        other_player = Player.create!(name: "Other Player", chips: 1000)
        service = PlayerGameActionService.new(room, other_player, "check", 0)

        expect { service.perform }.to raise_error("Jogador não está na sala")
      end

      it "invalid action" do
        service = PlayerGameActionService.new(room, player, "invalid_action", 0)

        expect { service.perform }.to raise_error("Ação inválida")
      end

      it "action not allowed in current state" do
        service = PlayerGameActionService.new(room, player, "check", 0)
        allow(service).to receive(:valid_action?).and_return(false)

        expect { service.perform }.to raise_error("Ação não permitida no estado atual: check")
      end

      it "insufficient chips for raise or call" do
        service = PlayerGameActionService.new(room, player, "raise", 2000)

        expect { service.perform }.to raise_error("Insufficient chips")
      end

      it "not player turn" do
        other_player = Player.create!(name: "Other Player", chips: 1000)
        room.player_join(other_player)
        game
        service = PlayerGameActionService.new(room, other_player, "check", 0)

        expect { service.perform }.to raise_error("Não é sua vez de jogar")
      end

      it "raise amount not greater than biggest bet" do
        game
        service = PlayerGameActionService.new(room, player, "raise", 50)
        allow(service).to receive(:biggest_bet).and_return(100)

        expect { service.perform }.to raise_error("A aposta deve ser maior que a maior aposta atual: 100")
      end

      it "call amount not equal to biggest bet" do
        GameAction.create!(
          player: player,
          game: game,
          action: "call",
          amount: 50,
          game_phase: game_phase
        )
        service = PlayerGameActionService.new(room, player, "call", 50)
        allow(service).to receive(:biggest_bet).and_return(100)

        expect { service.perform }.to raise_error("O valor do call deve ser exatamente igual à maior aposta atual: 100")
      end

      it "check when there is an active bet" do
        game
        service = PlayerGameActionService.new(room, player, "check", 0)
        allow(service).to receive(:biggest_bet).and_return(100)

        expect { service.perform }.to raise_error("Não é possível dar check se houver uma aposta ativa")
      end
    end

    context "happy path" do
      before do
        game
      end

      it "update current turn" do
        service = PlayerGameActionService.new(room, player, "check", 0)
        result = service.perform

        expect(result).to include("current_turn")
        expect(result["current_turn"]).to eq(1)
      end

      it "check action" do
        service = PlayerGameActionService.new(room, player, "check", 0)
        result = service.perform

        expect(result).to include("current_turn")
        expect(result).to include("pot")
        expect(player.reload.chips).to eq(1000)
      end

      it "call action" do
        GameAction.create!(
          player: player,
          game: game,
          action: "call",
          amount: 100,
          game_phase: game_phase
        )
        service = PlayerGameActionService.new(room, player, "call", 100)
        result = service.perform

        expect(result).to include("current_turn")
        expect(result).to include("pot")
        expect(player.reload.chips).to eq(900)
      end

      it "raise action" do
        service = PlayerGameActionService.new(room, player, "raise", 200)
        result = service.perform

        expect(result).to include("current_turn")
        expect(result).to include("pot")
        expect(player.reload.chips).to eq(800)
      end

      it "fold action" do
        service = PlayerGameActionService.new(room, player, "fold", 0)
        result = service.perform

        expect(result).to include("current_turn")
        expect(result).to include("pot")
        expect(player.reload.chips).to eq(1000)
      end
    end
  end
end
