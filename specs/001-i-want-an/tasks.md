# Tasks: Badminton Doubles Tournament Manager

**Input**: Design documents from `/home/axel-fpoc/badminton_draw/specs/001-i-want-an/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   ✓ Implementation plan found with web app structure
   ✓ Extracted: JavaScript/Material 3, localStorage, Docker deployment
2. Load optional design documents:
   ✓ data-model.md: Extracted Player, Round, Match, Tournament entities
   ✓ contracts/: Found TournamentService, StorageService, PairingService contracts
   ✓ research.md: Extracted Material 3 + minimal framework decisions
3. Generate tasks by category:
   ✓ Setup: project structure, package.json, Docker
   ✓ Tests: pairing logic, scoring calculations, tournament workflows
   ✓ Core: entity models, service implementations, UI pages
   ✓ Integration: service wiring, localStorage persistence
   ✓ Polish: manual testing, Docker optimization
4. Apply task rules:
   ✓ Different files marked [P] for parallel execution
   ✓ Same file tasks sequential (no [P])
   ✓ Critical business logic tests prioritized
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   ✓ All service contracts have implementations
   ✓ All entities have models
   ✓ All UI pages implemented
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Web app structure**: `src/` at repository root with feature-based organization
- **Testing**: `tests/` with integration and unit subdirectories
- **Docker**: Dockerfile and nginx config at repository root

## Phase 3.1: Setup
- [x] T001 Create project structure per implementation plan with src/, tests/, public/ directories
- [x] T002 Initialize package.json with Material 3 Web Components and Jest dependencies
- [x] T003 [P] Create Dockerfile with nginx for static file serving
- [x] T004 [P] Configure basic HTML template with Material 3 imports in public/index.html

## Phase 3.2: Tests for Critical Paths (Pragmatic Testing)
**IMPORTANT: Test only critical business logic and key workflows**
- [ ] T005 [P] Test pairing algorithm constraints in tests/unit/test_pairing_service.js
- [ ] T006 [P] Test scoring calculations (+2 winners, +1 losers) in tests/unit/test_tournament_service.js
- [ ] T007 [P] Test localStorage persistence and data validation in tests/unit/test_storage_service.js
- [ ] T008 [P] Integration test for complete tournament workflow in tests/integration/test_tournament_flow.js

**Note**: UI interactions will be tested manually per quickstart.md scenarios. Focus tests on business logic where bugs would break tournaments.

## Phase 3.3: Core Implementation - Data Models
- [x] T009 [P] Player entity model with validation in src/models/player.js
- [x] T010 [P] Round entity model with state transitions in src/models/round.js
- [x] T011 [P] Match entity model with pair validation in src/models/match.js
- [x] T012 [P] Tournament entity model with business rules in src/models/tournament.js

## Phase 3.4: Core Implementation - Services
- [ ] T013 PairingService implementation with Fisher-Yates shuffle in src/services/pairing.js
- [ ] T014 StorageService implementation with localStorage JSON persistence in src/services/storage.js
- [ ] T015 TournamentService implementation with player/round/match management in src/services/tournament.js

## Phase 3.5: UI Pages - Material 3 Components
- [ ] T016 [P] Players management page with add/edit/remove functionality in src/pages/players/
- [ ] T017 [P] Rounds page with generation and match display in src/pages/rounds/
- [ ] T018 [P] Scoring page with match result entry forms in src/pages/scoring/
- [ ] T019 [P] Rankings page with live score display in src/pages/rankings/

## Phase 3.6: Integration and Navigation
- [ ] T020 App shell with Material 3 tab navigation connecting all pages in src/app.js
- [ ] T021 Service integration - wire UI pages to business logic services
- [ ] T022 Data persistence integration - auto-save tournament state on changes
- [ ] T023 Error handling and user feedback for validation failures

## Phase 3.7: Polish (Minimal)
- [ ] T024 [P] Manual testing checklist document in manual-testing.md
- [ ] T025 [P] Docker optimization - minimize image size and startup time
- [ ] T026 [P] Basic responsive design for mobile compatibility
- [ ] T027 Final integration testing using quickstart.md scenarios

## Dependencies
- Setup (T001-T004) before everything else
- Entity models (T009-T012) before services (T013-T015)
- Services (T013-T015) before UI pages (T016-T019)
- UI pages before integration (T020-T023)
- Core functionality before polish (T024-T027)
- Tests (T005-T008) can be written after implementation if needed (pragmatic approach)

## Parallel Example
```
# Launch entity models together (Phase 3.3):
Task: "Player entity model with validation in src/models/player.js"
Task: "Round entity model with state transitions in src/models/round.js"
Task: "Match entity model with pair validation in src/models/match.js"
Task: "Tournament entity model with business rules in src/models/tournament.js"

# Launch UI pages together (Phase 3.5):
Task: "Players management page with add/edit/remove functionality in src/pages/players/"
Task: "Rounds page with generation and match display in src/pages/rounds/"
Task: "Scoring page with match result entry forms in src/pages/scoring/"
Task: "Rankings page with live score display in src/pages/rankings/"
```

## Key Implementation Notes
- **Material 3**: Use Material Web Components (not Angular Material)
- **Storage**: Simple JSON serialization to localStorage, no complex ORM
- **Testing**: Focus on pairing algorithm, scoring logic, and data persistence
- **Architecture**: Keep it simple - direct service calls from UI, no complex state management
- **Docker**: Single-stage build with nginx serving static files
- **Mobile**: Basic responsive design, not native mobile app

## Success Criteria per Task
- T001-T004: Project builds and runs locally + in Docker
- T005-T008: Critical business logic tests pass
- T009-T012: Data models validate according to specifications
- T013-T015: Services implement all contract methods correctly
- T016-T019: Each UI page handles its core user scenarios
- T020-T023: Complete tournament workflow functions end-to-end
- T024-T027: Manual testing scenarios from quickstart.md pass

## Manual Testing Integration
After T027, execute the complete test scenarios from quickstart.md:
1. Complete Tournament Flow (6 players, 2 rounds)
2. Odd Player Count (5 players with sitting rotation)
3. Data Persistence (browser refresh preserves state)
4. Error Handling (validation and edge cases)

This ensures the frugal, functional-first approach delivers a working tournament management tool that meets all user requirements.