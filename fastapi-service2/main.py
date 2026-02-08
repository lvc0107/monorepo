"""
FastAPI Service 2 - Microservice Template

A production-ready FastAPI microservice with proper error handling,
health checks, and logging.
"""
import logging
import os
from contextlib import asynccontextmanager
from typing import Dict

from fastapi import FastAPI
from fastapi.responses import JSONResponse

# Configure logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle management"""
    logger.info("Application startup")
    yield
    logger.info("Application shutdown")


app = FastAPI(
    title="FastAPI Service 2",
    description="A production-ready FastAPI microservice",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/", tags=["root"])
async def root() -> Dict[str, str]:
    """Root endpoint returning service information"""
    return {
        "message": "Welcome to FastAPI Service 2",
        "service": "fastapi-service2",
        "version": "1.0.0",
    }


@app.get("/health", tags=["health"])
async def health_check() -> Dict[str, str]:
    """Health check endpoint for readiness and liveness probes"""
    return {"status": "healthy", "service": "fastapi-service2"}


@app.get("/ready", tags=["health"])
async def readiness_check() -> Dict[str, str]:
    """Readiness check endpoint"""
    return {"ready": True, "service": "fastapi-service2"}


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=2222,
        log_level=os.getenv("LOG_LEVEL", "info").lower(),
    )

