# Tournament Service Contract

## TournamentService Interface

### Player Management

#### addPlayer(name: string): Player
**Purpose**: Add new player to tournament  
**Input**: 
- `name`: Non-empty string, must be unique
**Output**: 
- Returns Player object with generated ID
**Errors**: 
- Throws if name is empty or duplicate
- Throws if tournament is active

#### removePlayer(playerId: string): boolean
**Purpose**: Remove player from tournament  
**Input**: 
- `playerId`: Valid player UUID
**Output**: 
- Returns true if removed, false if not found
**Errors**: 
- Throws if tournament is active

#### updatePlayer(playerId: string, name: string): Player
**Purpose**: Update player name  
**Input**: 
- `playerId`: Valid player UUID
- `name`: New name (non-empty, unique)
**Output**: 
- Returns updated Player object
**Errors**: 
- Throws if name is duplicate or empty
- Throws if tournament is active

#### getPlayers(): Player[]
**Purpose**: Get all tournament players  
**Output**: 
- Returns array of Player objects ordered by score descending

### Round Management

#### generateRound(): Round
**Purpose**: Create new round with random pairings  
**Preconditions**: 
- Tournament has at least 4 players
- Previous round completed (if any)
**Output**: 
- Returns Round object with generated matches
**Errors**: 
- Throws if insufficient players
- Throws if previous round incomplete

#### getCurrentRound(): Round | null
**Purpose**: Get current active round  
**Output**: 
- Returns current Round object or null if none active

#### getRounds(): Round[]
**Purpose**: Get all tournament rounds  
**Output**: 
- Returns array of Round objects ordered by round number

### Match Management

#### recordMatchResult(matchId: string, winningPair: number): void
**Purpose**: Record match winner and update player scores  
**Input**: 
- `matchId`: Valid match UUID
- `winningPair`: 1 or 2 indicating winning pair
**Effects**: 
- Updates match winner
- Adds points to all 4 players (+2 winners, +1 losers)
- Updates round status if all matches complete
**Errors**: 
- Throws if match not found or already completed
- Throws if winningPair not 1 or 2

#### getMatch(matchId: string): Match | null
**Purpose**: Get specific match details  
**Input**: 
- `matchId`: Match UUID
**Output**: 
- Returns Match object or null if not found

### Tournament State

#### startTournament(): void
**Purpose**: Begin tournament (transition from setup to active)  
**Preconditions**: 
- At least 4 players added
**Effects**: 
- Changes tournament status to 'active'
- Prevents player list modifications
**Errors**: 
- Throws if insufficient players

#### resetTournament(): void
**Purpose**: Reset tournament scores, keep players  
**Effects**: 
- Clears all rounds and matches
- Resets all player scores to 0
- Changes status back to 'setup'

#### getTournamentStatus(): string
**Purpose**: Get current tournament phase  
**Output**: 
- Returns 'setup', 'active', or 'completed'

#### getRankings(): Player[]
**Purpose**: Get live player rankings  
**Output**: 
- Returns Player array sorted by score descending, name ascending (tiebreaker)