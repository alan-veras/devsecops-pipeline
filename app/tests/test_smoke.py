from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_items_lists_catalog():
    response = client.get("/items")
    assert response.status_code == 200
    assert len(response.json()["items"]) >= 1


def test_items_filters_by_query():
    response = client.get("/items", params={"q": "wid"})
    assert response.status_code == 200
    assert all("wid" in item["name"] for item in response.json()["items"])
