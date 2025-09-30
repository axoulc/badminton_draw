# Pairing Service Contract

## PairingService Interface

### Random Pairing Generation

#### generatePairings(players: Player[], previousRound?: Round): Match[]
**Purpose**: Create random doubles pairings with constraints  
**Input**: 
- `players`: Array of active players (4+ players)
- `previousRound`: Optional previous round for constraint checking
**Output**: 
- Returns array of Match objects with pair assignments
**Algorithm**: 
- Shuffle players randomly
- Group into pairs sequentially  
- Match pairs randomly against each other
- Handle odd players by sitting one out
**Constraints**: 
- No player paired with same partner as previous round
- Each player appears in exactly one match or sits out
**Errors**: 
- Throws if fewer than 4 players
- Throws if constraint satisfaction impossible

#### validatePairings(matches: Match[], previousRound?: Round): boolean
**Purpose**: Verify pairing constraints are satisfied  
**Input**: 
- `matches`: Array of matches to validate
- `previousRound`: Previous round for constraint checking
**Output**: 
- Returns true if all constraints satisfied
**Validation Rules**: 
- Each player appears exactly once across all matches
- No duplicate pairings from previous round
- All matches have exactly 4 unique players

### Constraint Management

#### findPreviousPartners(playerId: string, round: Round): string[]
**Purpose**: Get list of previous partners for a player  
**Input**: 
- `playerId`: Player to check
- `round`: Round to examine for partnerships
**Output**: 
- Returns array of player IDs who were partners

#### canPairPlayers(player1Id: string, player2Id: string, previousRound?: Round): boolean
**Purpose**: Check if two players can be paired together  
**Input**: 
- `player1Id`: First player ID
- `player2Id`: Second player ID  
- `previousRound`: Previous round for constraint checking
**Output**: 
- Returns true if pairing is allowed
**Rules**: 
- Always true if no previous round
- False if players were partners in previous round

### Randomization

#### shufflePlayers(players: Player[]): Player[]
**Purpose**: Randomly shuffle player order using Fisher-Yates algorithm  
**Input**: 
- `players`: Array of players to shuffle
**Output**: 
- Returns new array with players in random order
**Implementation**: 
- Uses cryptographically secure random if available
- Falls back to Math.random() for browser compatibility

#### selectSittingPlayer(players: Player[]): Player
**Purpose**: Randomly select which player sits out (odd numbers)  
**Input**: 
- `players`: Array of players (odd length)
**Output**: 
- Returns Player object who will sit out this round
**Algorithm**: 
- Random selection from all players
- Could be enhanced to rotate sitting players fairly