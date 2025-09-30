<!--
SYNC IMPACT REPORT
==================
Version Change: [initial template] → 1.0.0
Constitution Type: Initial creation for badminton_draw project

Modified/Added Principles:
- NEW: I. Frugal Development - Focus on functional MVP with minimal overhead
- NEW: II. Functional First - Prioritize working features over perfection
- NEW: III. Pragmatic Testing - Test-light approach with focus on critical paths only
- NEW: IV. Simple Architecture - Straightforward code structure without over-engineering

Added Sections:
- Development Workflow - Code review, quality gates, commit standards
- Governance - Amendment process, version policy, compliance review

Templates Status:
✅ plan-template.md - Updated constitution check section with frugal principles
✅ spec-template.md - Added frugal guideline for minimal viable requirements  
✅ tasks-template.md - Updated testing approach, removed TDD requirement, pragmatic focus

Command Files Status:
✅ No command files found in .specify/templates/commands/

Runtime Guidance Status:
✅ No README.md or agent-specific files found requiring updates

Follow-up TODOs:
- None (all placeholders filled, all dependent templates updated)

Date: 2025-09-30
-->

# Badminton Draw Constitution

## Core Principles

### I. Frugal Development
**MUST** maintain a lean development approach throughout the project lifecycle:
- Minimize dependencies: Only add libraries when absolutely necessary
- Avoid gold-plating: Implement features to "good enough" standard, not perfect
- Reject premature optimization: Build simple solutions first, optimize only if needed
- Keep infrastructure minimal: No complex build systems, deployment pipelines, or tooling unless required

**Rationale**: This is a utility project for badminton draw management. Speed of delivery and maintainability trump enterprise-grade architecture. Resources are limited and must be focused on core functionality.

### II. Functional First
**MUST** prioritize working software over aesthetics or technical elegance:
- UI must be functional, not beautiful: Clean and usable beats polished design
- Code clarity over cleverness: Straightforward implementations preferred
- Feature completeness: Get the full workflow working before refining details
- User workflow validation: Manual testing of end-to-end scenarios is mandatory

**Rationale**: Users need a tool that works reliably for draw management. A working "not too ugly" interface delivers more value than a beautiful but incomplete one.

### III. Pragmatic Testing
**MUST** apply a test-light philosophy focused on critical paths:
- Test critical business logic only: Draw generation, player assignments, validation rules
- Skip testing simple getters/setters and boilerplate code
- Integration tests for key workflows: Creating draws, managing players, generating outputs
- No TDD requirement: Write tests after implementation for complex logic only
- Manual testing is acceptable: Document test scenarios in manual-testing.md for UI flows

**Rationale**: Overly large test benches add maintenance burden without proportional value. Focus testing effort where bugs would cause the most harm.

### IV. Simple Architecture
**MUST** keep the codebase structure straightforward and maintainable:
- Single-tier structure acceptable: No forced separation into libraries unless natural boundaries exist
- Direct implementations: Avoid abstraction layers, interfaces, or design patterns unless solving a real problem
- Minimal configuration: Hardcode reasonable defaults, make configurable only what users must change
- Clear file organization: Group by feature or domain, not by technical layer

**Rationale**: This project doesn't need enterprise patterns. A simple, readable codebase is easier to maintain and modify as requirements evolve.

## Development Workflow

**Code Review Requirements**:
- Self-review is acceptable for small changes
- Peer review recommended for complex logic or architectural decisions
- Constitution compliance check: Verify changes don't introduce unnecessary complexity

**Quality Gates**:
- Code must compile/run without errors
- Critical paths must have integration tests
- Manual testing checklist completed for user-facing changes
- Documentation updated for new features (quickstart.md, README)

**Commit Standards**:
- Frequent, working commits preferred over large changesets
- Commit messages should explain "why" not "what"
- Each commit should leave the codebase in a runnable state

## Governance

This constitution supersedes all other development practices and preferences. All decisions must align with the frugal, functional-first philosophy.

**Amendment Process**:
1. Propose amendment with rationale in writing
2. Increment version per semantic versioning rules
3. Update this document with changes and date
4. Propagate changes to affected templates and documentation
5. Document migration steps if breaking changes

**Version Policy**:
- MAJOR: Changes to core principles or removal of mandatory requirements
- MINOR: Addition of new principles or substantial guidance updates
- PATCH: Clarifications, corrections, non-semantic improvements

**Compliance Review**:
- All feature specs must pass constitution alignment check
- Implementation plans must justify any complexity increases
- Tasks must follow pragmatic testing guidelines
- Regular retrospectives to ensure principles remain relevant

**Version**: 1.0.0 | **Ratified**: 2025-09-30 | **Last Amended**: 2025-09-30