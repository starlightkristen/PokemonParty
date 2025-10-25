# Simple certificates router (mock) for Award Ceremony button.
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os, json, time
from typing import List, Optional

router = APIRouter()

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "server", "data")
os.makedirs(DATA_DIR, exist_ok=True)
CERT_PATH = os.path.join(DATA_DIR, "certificates.json")

class CertRequest(BaseModel):
    roster: Optional[List[dict]] = None
    expedition_id: Optional[str] = "expedition-unknown"

@router.post("/generate-batch")
def generate_batch(req: CertRequest):
    try:
        record = {
            "expedition_id": req.expedition_id,
            "roster_count": len(req.roster) if req.roster else 0,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "status": "queued"
        }
        data = []
        if os.path.exists(CERT_PATH):
            try:
                with open(CERT_PATH, "r", encoding="utf-8") as f:
                    data = json.load(f)
            except Exception:
                data = []
        data.append(record)
        with open(CERT_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        return {"status": "ok", "message": "Certificates queued", "record": record}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
