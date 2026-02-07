# FastAPI Service

A simple FastAPI application with a hello world endpoint.

## Installation

```bash
pip install -r requirements.txt
```

## Running Locally

```bash
uvicorn main:app --reload
```

The API will be available at http://localhost:2222

## Endpoints

- `GET /` - Returns a hello world message
- `GET /health` - Health check endpoint
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation (ReDoc)

## Example Request

```bash
curl http://localhost:2222/
```

Response:
```json
{
  "message": "Hello World from FastAPI!"
}
```

## Deployment

You can deploy this using various methods:
- Docker container
- Cloud services (AWS ECS, Google Cloud Run, Azure Container Apps)
- Traditional servers with Gunicorn + Uvicorn workers
