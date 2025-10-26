from fastapi import FastAPI, APIRouter, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import threading

app = FastAPI(title="PokemonParty Mock Server")

# Allow CORS for local testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

lock = threading.Lock()

# In-memory state
state = {
    "animals": [
        {"id": "rabbit", "name": "Rabbit"},
        {"id": "goat", "name": "Goat"},
        {"id": "lizard", "name": "Lizard"},
    ],
    "current_animal": "rabbit",
    "roster": [],
    "scene": "WELCOME",
    "progress": 0,
    "votes": {},
    "hold": {"stopped": False},
}

# Pydantic models
class AnimalCurrent(BaseModel):
    id: str

class CheckinManual(BaseModel):
    name: str

class SceneGoto(BaseModel):
    to: str

class SceneProgress(BaseModel):
    delta: int

class VoteStart(BaseModel):
    id: str
    options: list
    label: str = ""

class VoteResult(BaseModel):
    id: str
    winner: str
    percent: int

@app.get("/api/health")
async def health():
    return {"status": "ok"}

@app.get("/api/animals/catalog")
async def animals_catalog():
    return {"animals": state["animals"]}

@app.get("/api/animals/current")
async def get_current_animal():
    return {"status": "ok", "current": state.get("current_animal", "rabbit")}

@app.post("/api/animals/current")
async def set_current_animal(payload: AnimalCurrent):
    with lock:
        ids = [a["id"] for a in state["animals"]]
        if payload.id not in ids:
            raise HTTPException(status_code=404, detail="animal not found")
        state["current_animal"] = payload.id
    return {"status": "ok", "current": state["current_animal"]}

@app.post("/api/checkin/manual")
async def manual_checkin(payload: CheckinManual):
    with lock:
        entry = {"name": payload.name}
        state["roster"].append(entry)
    return {"status": "ok", "entry": entry}

@app.get("/api/roster")
async def get_roster():
    return state["roster"]

@app.post("/api/scene/goto")
async def scene_goto(payload: SceneGoto):
    with lock:
        state["scene"] = payload.to
    return {"status": "ok", "scene": state["scene"]}

@app.get("/api/scene/state")
async def scene_state():
    return {"data": {"scene": state.get("scene")}}

@app.post("/api/scene/progress")
async def scene_progress(payload: SceneProgress):
    with lock:
        state["progress"] = state.get("progress", 0) + int(payload.delta)
    return {"status": "ok", "progress": state["progress"]}

@app.post("/api/vote/start")
async def vote_start(payload: VoteStart):
    with lock:
        state["votes"][payload.id] = {"options": payload.options, "label": payload.label, "result": None}
    return {"status": "ok", "id": payload.id}

@app.post("/api/vote/result")
async def vote_result(payload: VoteResult):
    with lock:
        v = state["votes"].get(payload.id)
        if not v:
            raise HTTPException(status_code=404, detail="vote not found")
        v["result"] = {"winner": payload.winner, "percent": payload.percent}
    return {"status": "ok", "id": payload.id, "result": v["result"]}

@app.get("/api/votes")
async def get_votes():
    return state["votes"]

@app.post("/api/hold/stop")
async def hold_stop():
    with lock:
        state["hold"]["stopped"] = True
    return {"status": "ok"}

# Fallback for other API endpoints used in tests (safe no-op)
@app.post("/api/{path:path}")
async def api_catchall(path: str, request: Request):
    # Return a generic success for unknown POST endpoints to keep tests moving.
    return JSONResponse({"status": "ok", "path": path})

# Mount static files AFTER API routes to avoid conflicts
app.mount("/", StaticFiles(directory="frontend", html=True), name="frontend")
