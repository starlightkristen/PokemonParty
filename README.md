[![Playwright CI](https://github.com/starlightkristen/PokemonParty/actions/workflows/playwright-ci.yml/badge.svg)](https://github.com/starlightkristen/PokemonParty/actions/workflows/playwright-ci.yml)

# PokemonParty

🎮 **Interactive Pokémon-themed web application with 100% test coverage!**

## 🎯 Project Status

- ✅ **CI/CD Pipeline:** Fully automated with GitHub Actions
- ✅ **Test Coverage:** 100% (8/8 tests passing)
- ✅ **Backend:** FastAPI with 12 operational endpoints
- ✅ **Frontend:** 4 interactive pages
- ✅ **Quality:** Dependabot + nightly smoke tests

## 🚀 Quick Start

### Prerequisites
- Python 3.x
- Node.js 20+
- npm

### Local Development

```bash
# Install Python dependencies
pip install -r server/requirements.txt

# Install Node dependencies
npm ci

# Start backend server
python -m uvicorn server.app.main:app --host 127.0.0.1 --port 8000

# Run Playwright tests (in another terminal)
npx playwright test
```

## 📊 Test Suite

The project includes **8 comprehensive integration tests** with **100% pass rate**:

### Phase 1 Tests (`phase1.spec.ts`):
1. ✅ **API Health and Animals Catalog** - Validates backend endpoints
2. ✅ **Manual check-in API and roster** - Tests user registration flow
3. ✅ **Welcome page navigation** - Validates page routing
4. ✅ **Habitat animal switch** - Tests dynamic content updates
5. ✅ **Scene progress updates** - Validates UI state management
6. ✅ **Session persistence** - Tests state recovery

### Specialized Tests:
7. ✅ **Hold Type Scanner** (`hold-scanner.spec.ts`) - Uses `?showWinner=1` for deterministic testing
8. ✅ **Welcome navigation** (`welcome.spec.ts`) - Independent navigation validation

### Test Features:
- 🎯 **Deterministic execution** via query parameters
- ⚡ **Fast execution** (< 10 seconds total)
- 🔄 **Nightly smoke tests** (5 AM UTC)
- 📊 **Automatic report generation**

## 🛠️ Architecture

- **Backend:** FastAPI (Python)
- **Frontend:** HTML/CSS/JavaScript
- **Testing:** Playwright
- **CI/CD:** GitHub Actions
- **Automation:** PowerShell toolkit

## 📝 Contributing

Pull requests are welcome! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) guide for details on:
- Setting up your development environment
- Running tests locally
- Making quality pull requests
- Code review process

All PRs require:
- ✅ Passing CI checks (all 8 tests must pass)
- ✅ Code owner review (@starlightkristen)
- ✅ Updated documentation (if applicable)

## 📜 License

MIT License - feel free to use this project as a template!

---

**Built with ❤️ and 100% automated CI/CD**
