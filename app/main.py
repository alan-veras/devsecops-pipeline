from fastapi import FastAPI

app = FastAPI(title="devsecops-pipeline", version="1.0.0")

ITEMS = [
    {"id": 1, "name": "widget"},
    {"id": 2, "name": "gadget"},
    {"id": 3, "name": "gizmo"},
]


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/items")
def list_items(q: str | None = None) -> dict:
    if q is None:
        return {"items": ITEMS}
    needle = q.lower()
    return {"items": [item for item in ITEMS if needle in item["name"].lower()]}
