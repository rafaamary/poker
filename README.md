## 🎯 Sobre o Projeto

Esta API permite criar e gerenciar jogos de poker multiplayer em tempo real. Os jogadores podem criar salas, entrar em jogos, fazer apostas e acompanhar o progresso do jogo através de WebSockets.

## ✨ Funcionalidades

### 🎮 Gestão de Jogos
- ✅ Criação e gestão de salas de poker
- ✅ Sistema de fases do jogo (pré-flop, flop, turn, river)
- ✅ Distribuição automática de cartas
- ✅ Cálculo automático de vencedores
- ✅ Gestão de pot e apostas

### 👥 Gestão de Jogadores
- ✅ Cadastro de jogadores
- ✅ Sistema de chips
- ✅ Histórico de ações no jogo

### 🔄 Tempo Real
- ✅ Comunicação via WebSocket (ActionCable)
- ✅ Atualizações em tempo real do estado do jogo
- ✅ Notificações de ações dos jogadores

### 🎯 Ações do Poker
- ✅ Check, Call, Raise, Fold
- ✅ Showdown automático
- ✅ Validação de regras do poker


## 📁 Estrutura do Projeto

```
app/
├── channels/           # WebSocket channels
│   ├── application_cable/
│   └── game_channel.rb
├── controllers/        # API endpoints
│   ├── players_controller.rb
│   └── rooms_controller.rb
├── models/            # Modelos de dados
│   ├── player.rb
│   ├── room.rb
│   ├── game.rb
│   ├── game_phase.rb
│   └── game_action.rb
├── serializers/       # Serialização JSON
│   ├── player_serializer.rb
│   └── room_serializer.rb
└── services/          # Lógica de negócio
    ├── end_game_service.rb
    ├── next_phase_service.rb
    └── player_game_action_service.rb
```

## 🚀 Como Executar

### Pré-requisitos
- Ruby 3.3.0
- PostgreSQL
- Bundler

### Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd poker
```

2. **Instale as dependências**
```bash
bundle install
```

3. **Configure o banco de dados**
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

4. **Configure o ActionCable**
```bash
bin/rails solid_cable:install
bin/rails db:migrate
```

5. **Inicie o servidor**
```bash
bin/rails server
```

A API estará disponível em `http://localhost:3000`

## 📡 Endpoints da API

### 👥 Jogadores
```http
POST /players          # Criar jogador
DELETE /players/:id    # Remover jogador
```

### 🏠 Salas
```http
POST /rooms                    # Criar sala
GET /rooms                     # Listar salas
POST /rooms/:id/join          # Entrar na sala
POST /rooms/:id/leave         # Sair da sala
POST /rooms/:id/start         # Iniciar jogo
POST /rooms/:id/action        # Fazer ação no jogo
POST /rooms/:id/next-phase    # Próxima fase
POST /rooms/:id/end           # Finalizar jogo
```

### 🔌 WebSocket
```
WS /cable                     # Conexão WebSocket
```

## 🎮 Como Jogar

### 1. Criar um Jogador
```bash
curl -X POST http://localhost:3000/players \
  -H "Content-Type: application/json" \
  -d '{"name": "João", "chips": 1000}'
```

### 2. Criar uma Sala
```bash
curl -X POST http://localhost:3000/rooms \
  -H "Content-Type: application/json" \
  -d '{"name": "Sala VIP", "max_players": 6}'
```

### 3. Entrar na Sala
```bash
curl -X POST http://localhost:3000/rooms/1/join \
  -H "Content-Type: application/json" \
  -d '{"player_id": 1}'
```

## 🧪 Testes

Execute os testes com:

```bash
bundle exec rspec
```

## 🏗️ Arquitetura

### Modelos Principais

- **Player** - Representa um jogador com chips
- **Room** - Sala de poker com configurações
- **Game** - Instância de um jogo em uma sala
- **GamePhase** - Fases do jogo (pré-flop, flop, turn, river)
- **GameAction** - Ações dos jogadores (check, call, raise, fold)

### Services

- **EndGameService** - Finaliza o jogo e determina vencedor
- **NextPhaseService** - Avança para próxima fase do jogo
- **PlayerGameActionService** - Processa ações dos jogadores

### WebSocket (ActionCable)

- **GameChannel** - Canal principal para comunicação em tempo real
  - `join_game` - Entrar em um jogo
  - `start_game` - Iniciar jogo
  - `leave_game` - Sair do jogo
  - `game_action` - Fazer ação no jogo

### 🎯 Status do Projeto: Em Desenvolvimento Ativo

> **Nota**: Este projeto está em desenvolvimento ativo. Algumas funcionalidades podem estar em fase de implementação.
