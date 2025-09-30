
# Implementation Plan: Badminton Doubles Tournament Manager

**Branch**: `001-i-want-an` | **Date**: 2025-09-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/home/axel-fpoc/badminton_draw/specs/001-i-want-an/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Primary requirement: Web-based tournament management system for badminton doubles with random pairing, scoring (+2 winners, +1 losers), and live ranking display. Technical approach: Material 3 web interface with multi-page navigation and Docker deployment capabilities.

## Technical Context
**Language/Version**: JavaScript/TypeScript (ES2022), HTML5, CSS3  
**Primary Dependencies**: Material 3 Web Components, minimal web framework (Vue.js or vanilla JS)  
**Storage**: Browser localStorage for persistence (simple JSON data)  
**Testing**: Jest for JavaScript unit tests, manual testing for UI workflows  
**Target Platform**: Modern web browsers (Chrome, Firefox, Safari, Edge)
**Project Type**: web - frontend-focused single-page application with multiple tabs/pages  
**Performance Goals**: <2s initial load, <500ms navigation between pages  
**Constraints**: Offline-capable preferred, mobile-responsive design  
**Scale/Scope**: Small tournaments (4-20 players), lightweight deployment with Docker

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Frugal Development
- [x] Dependencies minimized: Material 3 Web Components + minimal framework, localStorage storage
- [x] No premature optimization: Simple SPA architecture, no complex state management
- [x] Infrastructure kept minimal: Docker for deployment only, no build pipelines beyond basic bundling
- [x] "Good enough" standard: Functional UI over polished design, core workflows prioritized

### II. Functional First  
- [x] Working software prioritized: Complete tournament workflow before UI polish
- [x] Code clarity over cleverness: Direct DOM manipulation or simple framework usage
- [x] End-to-end validation planned: Manual testing scenarios for tournament flows

### III. Pragmatic Testing
- [x] Test scope limited: Test pairing logic, scoring calculations, data persistence only
- [x] No TDD requirement: Implement first, test critical business logic after
- [x] Manual testing acceptable: UI interactions tested manually with quickstart scenarios
- [x] Test-light approach: Skip testing simple form handlers and display logic

### IV. Simple Architecture
- [x] Structure straightforward: Feature-based organization (players, rounds, scoring)
- [x] Minimal configuration: Reasonable defaults for tournament settings
- [x] Clear organization: Group by tournament features, not MVC layers
- [x] Direct implementations: Plain JavaScript/DOM APIs where sufficient

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
src/
├── components/          # Material 3 web components
├── pages/              # Tournament pages/tabs
│   ├── players/        # Player management page
│   ├── rounds/         # Round generation and match display
│   ├── scoring/        # Match result entry
│   └── rankings/       # Live rankings display
├── services/           # Business logic
│   ├── tournament.js   # Tournament state management
│   ├── pairing.js      # Random pairing algorithms
│   └── storage.js      # localStorage persistence
└── assets/             # CSS, Material 3 theme files

tests/
├── integration/        # End-to-end tournament workflows
└── unit/              # Business logic tests (pairing, scoring)

public/
├── index.html         # Main entry point
└── manifest.json      # PWA manifest (optional)

Dockerfile             # Container deployment
package.json           # Dependencies and scripts
```

**Structure Decision**: Web application with frontend-only architecture using Material 3 design system. Feature-based page organization with shared services for business logic. Simple build process with Docker containerization for deployment.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh copilot`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (data-model.md, contracts/, quickstart.md)
- Core business logic tests: Pairing algorithms, scoring calculations, data persistence
- Service implementation tasks: TournamentService, StorageService, PairingService
- UI component tasks: Player management, round display, scoring interface, rankings
- Integration tasks: Service wiring, localStorage persistence, Docker deployment

**Specific Task Categories**:
1. **Setup Tasks**: Project structure, package.json, Docker configuration
2. **Critical Logic Tests**: Pairing constraints, scoring rules, data validation  
3. **Service Implementation**: Business logic services per contracts
4. **UI Pages**: Material 3 components for each tournament phase
5. **Integration**: Service connections, persistence, navigation
6. **Deployment**: Docker optimization, static file serving

**Ordering Strategy**:
- Foundation first: Project setup, core services
- Business logic before UI: Services implemented before pages consume them
- Feature-complete pages: Each page fully functional before moving to next
- Integration and deployment last
- Mark [P] for parallel execution where files don't conflict

**Estimated Output**: 20-25 numbered tasks focusing on essential functionality

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
