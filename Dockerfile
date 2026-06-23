# Single-image build: compile the React frontend, then run the FastAPI backend
# which serves both that built frontend and the API on one origin/port.
# No native system libraries are needed — resvg-py, Pillow, and PyMuPDF all ship
# self-contained wheels (the old cairosvg/libcairo dependency is gone).

# --- stage 1: build the React frontend -> /fe/dist ---
FROM node:20-slim AS frontend
WORKDIR /fe
COPY app/frontend/package*.json ./
RUN npm ci
COPY app/frontend/ ./
RUN npm run build

# --- stage 2: backend + built frontend, one service ---
FROM python:3.12-slim
WORKDIR /srv/app/backend

COPY app/backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app/backend/ ./
# Built SPA goes where main.py looks for it: <backend>/../frontend/dist
COPY --from=frontend /fe/dist /srv/app/frontend/dist

# File storage (until the Vercel Blob migration). Mount a volume on
# /srv/app/backend/data in deployment to persist properties + the sheet library.
RUN mkdir -p data/uploads data/sheets data/properties

ENV PORT=8000
EXPOSE 8000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
