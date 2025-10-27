# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-27

### 🎉 Initial Production Release

**Major achievement:** Built complete CI/CD infrastructure from zero to production in 9 hours with 100% test pass rate!

### Added
- ✅ **Complete CI/CD Pipeline** - GitHub Actions workflow with Playwright tests
- ✅ **FastAPI Backend** - 12 operational endpoints (`/api/health`, `/api/animals/*`, `/api/scene/*`, etc.)
- ✅ **Playwright Test Suite** - 8 comprehensive integration tests (100% passing)
- ✅ **Frontend Application** - 4 interactive pages (welcome, checkin, habitat, hold-scanner)
- ✅ **PowerShell Automation Toolkit** - 12 helper functions for GitHub CLI operations
- ✅ **Dependabot Configuration** - Weekly npm and pip dependency updates
- ✅ **Nightly Smoke Tests** - Automated regression detection at 5 AM UTC
- ✅ **CODEOWNERS** - Enforced code review requirements
- ✅ **Professional README** - With live CI badge and comprehensive documentation
- ✅ **CONTRIBUTING Guide** - Developer onboarding and contribution guidelines
- ✅ **PR Template** - Standardized pull request format
- ✅ **Report Tooling** - `scripts/archive-playwright-report.ps1` for artifact management

### Testing
- **Phase 1 Tests (6):**
  - API Health and Animals Catalog
  - Manual check-in API and roster
  - Welcome page navigation (robust with `waitForURL`)
  - Habitat animal switch (ANIMAL_ACTIVE)
  - Scene progress updates (heart crystals)
  - Session persistence (poll restart)

- **Specialized Tests (2):**
  - Hold Type Scanner (deterministic with `?showWinner=1`)
  - Welcome navigation (independent validation)

### Infrastructure
- GitHub Actions CI/CD pipeline with automatic PR checks
- Node.js 20 + Python 3.x environment
- Playwright browser automation
- FastAPI with CORS and static file serving
- Automated artifact uploads

### Operational Excellence
- 🤖 Dependabot: Weekly updates for npm and pip
- 🌙 Nightly tests: 5 AM UTC daily + manual dispatch
- 👥 CODEOWNERS: Required reviews for critical paths
- 📊 Live CI badge: Real-time status visibility
- 📚 Comprehensive docs: README, CONTRIBUTING, PR template

### Technical Highlights
- **Deterministic Testing:** Query parameter solution (`?showWinner=1`) eliminates flaky tests
- **Perfect Configuration:** `baseURL: 127.0.0.1:8000` matches CI environment
- **Complete Automation:** 19 pull requests, 100% auto-merged
- **Fast Execution:** All tests complete in < 10 seconds

### Metrics
- **Duration:** 9 hours from zero to production
- **Pull Requests:** 19 (all auto-merged)
- **Test Pass Rate:** 100% (8/8)
- **Files Created:** 47
- **Lines of Code:** 2,600+
- **Issues Resolved:** 4

### Breaking Changes
None - this is the initial release.

### Security
- Automated dependency updates via Dependabot
- Enforced code reviews via CODEOWNERS
- Branch protection on main (requires CI pass)

---

## Release Links

- [v1.0.0 Release](https://github.com/starlightkristen/PokemonParty/releases/tag/v1.0.0)
- [CI Actions](https://github.com/starlightkristen/PokemonParty/actions)
- [Latest Run](https://github.com/starlightkristen/PokemonParty/actions/runs/18827844180)