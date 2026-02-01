from fastapi import FastAPI

app = FastAPI(title="Hello World API")


@app.get("/")
async def hello_world():
    """Simple hello world endpoint"""
    return {"message": "Hello World from FastAPI!"}


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
