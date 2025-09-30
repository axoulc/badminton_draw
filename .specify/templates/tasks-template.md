# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 3.1: Setup
- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

## Phase 3.2: Tests for Critical Paths (Pragmatic Testing)
**IMPORTANT: Test only critical business logic and key workflows**
- [ ] T004 [P] Integration test for [critical workflow 1] in tests/integration/test_[workflow].py
- [ ] T005 [P] Integration test for [critical workflow 2] in tests/integration/test_[workflow2].py
- [ ] T006 [P] Test for [complex business logic] in tests/unit/test_[logic].py

**Note**: Skip testing simple getters/setters, boilerplate, and straightforward CRUD. Tests can be written AFTER implementation. Manual testing documented in manual-testing.md is acceptable for UI flows.

## Phase 3.3: Core Implementation
- [ ] T007 [P] [Entity] model in src/models/[entity].py
- [ ] T008 [P] [Service] implementation in src/services/[service].py
- [ ] T009 [P] CLI command for [action] in src/cli/[commands].py
- [ ] T010 [Endpoint/UI] implementation
- [ ] T011 Input validation for critical fields
- [ ] T012 Error handling for key scenarios

## Phase 3.4: Integration (If Needed)
- [ ] T013 Connect services to storage/data layer
- [ ] T014 Add basic logging for debugging
- [ ] T015 Error handling middleware (if applicable)

## Phase 3.5: Polish (Minimal)
- [ ] T016 [P] Additional tests for complex logic (if needed) in tests/unit/test_[component].py
- [ ] T017 [P] Update quickstart.md with usage instructions
- [ ] T018 Manual testing checklist in manual-testing.md
- [ ] T019 Code cleanup: Remove obvious duplication only

## Dependencies
- Critical tests (T004-T006) can be written after implementation if needed
- Models (T007) before services (T008)
- Core implementation (T007-T012) before integration (T013-T015)
- Implementation before minimal polish (T016-T019)

## Parallel Example
```
# Launch T004-T006 together (if doing tests first):
Task: "Integration test for [workflow 1] in tests/integration/test_[workflow].py"
Task: "Integration test for [workflow 2] in tests/integration/test_[workflow2].py"
Task: "Test for [complex logic] in tests/unit/test_[logic].py"

# Or launch implementation tasks together:
Task: "[Entity] model in src/models/[entity].py"
Task: "[Service] implementation in src/services/[service].py" 
Task: "CLI command for [action] in src/cli/[commands].py"
```

## Notes
- [P] tasks = different files, no dependencies
- Tests can be written after implementation (pragmatic approach)
- Focus testing on critical business logic only
- Commit after each task
- Avoid: vague tasks, same file conflicts, over-testing boilerplate code

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task