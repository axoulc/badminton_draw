# Data Model: Badminton Doubles Tournament Manager

## Core Entities

### Player
**Purpose**: Represents a tournament participant with scoring state  
**Attributes**:
- `id`: Unique identifier (string, generated UUID)
- `name`: First name only (string, required, unique)
- `score`: Cumulative points across all rounds (integer, default 0)
- `isActive`: Whether player participates in current round (boolean, default true)

**Validation Rules**:
- Name must be non-empty string
- Name must be unique within tournament
- Score cannot be negative
- ID must be unique and immutable

**State Transitions**:
- Created → Active (added to tournament)
- Active → Inactive (sits out due to odd numbers)
- Inactive → Active (rejoins in subsequent rounds)

### Round
**Purpose**: Represents a single tournament round with generated matches  
**Attributes**:
- `id`: Unique identifier (string, generated UUID) 
- `number`: Round sequence number (integer, starting from 1)
- `matches`: Array of Match objects for this round
- `status`: Round state (enum: 'planned', 'in-progress', 'completed')
- `createdAt`: Timestamp when round was generated (Date)

**Validation Rules**:
- Round number must be positive integer
- Matches array cannot be empty
- All matches must reference valid players
- Cannot modify completed rounds

**State Transitions**:
- Planned → In-Progress (first match result recorded)
- In-Progress → Completed (all match results recorded)

### Match
**Purpose**: Represents a doubles match between two pairs  
**Attributes**:
- `id`: Unique identifier (string, generated UUID)
- `pair1`: Array of 2 Player IDs (first team)
- `pair2`: Array of 2 Player IDs (opposing team)  
- `winner`: Winning pair number (integer: 1 or 2, null if not played)
- `status`: Match state (enum: 'pending', 'completed')

**Validation Rules**:
- Each pair must contain exactly 2 different players
- No player can appear in both pairs of same match
- Winner must be 1 or 2 if status is 'completed'
- Cannot modify completed matches

**State Transitions**:
- Pending → Completed (winner recorded)

### Tournament
**Purpose**: Root aggregate containing all tournament state  
**Attributes**:
- `id`: Unique identifier (string, generated UUID)
- `name`: Tournament name (string, optional, default "Badminton Tournament")
- `players`: Array of Player objects
- `rounds`: Array of Round objects
- `currentRound`: Current round number (integer, null if not started)
- `status`: Tournament state (enum: 'setup', 'active', 'completed')
- `createdAt`: Tournament creation timestamp (Date)
- `settings`: Configuration object with scoring rules

**Validation Rules**:
- Must have at least 4 players to start
- Current round must reference existing round
- Cannot add players during active tournament
- Settings cannot be modified after tournament starts

**State Transitions**:
- Setup → Active (first round generated)
- Active → Completed (all desired rounds finished)
- Completed → Setup (reset tournament, keep players)

## Relationships

### Player ↔ Tournament
- One-to-many: Tournament contains multiple Players  
- Cascade: Deleting tournament removes all associated players

### Tournament ↔ Round  
- One-to-many: Tournament contains multiple Rounds
- Ordered: Rounds have sequential numbering
- Cascade: Deleting tournament removes all rounds

### Round ↔ Match
- One-to-many: Round contains multiple Matches
- Lifecycle: All matches must be completed to complete round

### Player ↔ Match  
- Many-to-many: Each match references 4 players, each player appears in multiple matches
- Constraint: No player paired with same partner in consecutive rounds

## Data Persistence Schema

### localStorage Structure
```javascript
{
  "tournament": {
    "id": "uuid",
    "name": "string",
    "status": "setup|active|completed", 
    "currentRound": "number|null",
    "createdAt": "ISO date string",
    "settings": {
      "winnerPoints": 2,
      "loserPoints": 1
    }
  },
  "players": [
    {
      "id": "uuid",
      "name": "string",
      "score": "number", 
      "isActive": "boolean"
    }
  ],
  "rounds": [
    {
      "id": "uuid",
      "number": "number",
      "status": "planned|in-progress|completed",
      "createdAt": "ISO date string",
      "matches": [
        {
          "id": "uuid",
          "pair1": ["player-id", "player-id"],
          "pair2": ["player-id", "player-id"],
          "winner": "1|2|null",
          "status": "pending|completed"
        }
      ]
    }
  ]
}
```

## Business Rules

### Pairing Constraints
1. **No consecutive partners**: Player cannot be paired with same partner in consecutive rounds
2. **Fair rotation**: Each player should play against different opponents across rounds  
3. **Odd player handling**: One player sits out per round if total players is odd
4. **Random selection**: Pair generation must be random within constraints

### Scoring Rules
1. **Winner points**: Each player in winning pair gets +2 points
2. **Loser points**: Each player in losing pair gets +1 point  
3. **Sitting out**: Player sitting out gets 0 points for that round
4. **Cumulative scoring**: Player total is sum across all completed rounds

### Tournament Flow Rules
1. **Setup phase**: Add/remove/edit players freely
2. **Active phase**: Cannot modify player list, can only record results
3. **Round completion**: All matches must have results before new round
4. **Tournament completion**: Manual decision by organizer
5. **Reset capability**: Clear all scores but preserve player list