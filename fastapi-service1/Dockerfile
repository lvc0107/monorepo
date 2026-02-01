FROM python:3.11-slim

WORKDIR /app

# Copiamos requirements primero (caché de Docker)
COPY requirements.txt .

# Instalamos dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el código de la app
COPY main.py .

EXPOSE 8000

# Comando para correr la app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
