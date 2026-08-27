# IoT Data Platform

REST API för insamling, validering och lagring av sensordata från tre simulerade
IoT-enheter. Byggd med Flask, PostgreSQL och Redis, körs lokalt i Docker Compose
med CI via GitHub Actions och en Kubernetes-demo i Minikube.

## Arkitektur

Se [docs/architecture.md](docs/architecture.md) för diagram och beskrivning.

## Kom igång

```bash
docker compose up --build -d
docker compose ps
```

API:t nås på `http://localhost:5001`. Vänta tills `db` visar `healthy`.

Är port 5001 upptagen: `API_PORT=5002 docker compose up --build -d`

Stoppa: `docker compose down` (volymen med databasen behålls)

## Endpoints

| Metod | Path | Beskrivning | Statuskoder |
|---|---|---|---|
| GET | `/health` | Hälsokontroll | 200 |
| GET | `/devices` | Lista alla sensorer | 200 |
| GET | `/measurements` | Senaste 100 mätningarna | 200 |
| GET | `/devices/{id}/latest` | Senaste mätningen (cache-aside) | 200, 404 |
| GET | `/devices/{id}/measurements` | Historik för en sensor | 200, 404 |
| POST | `/measurements` | Ta emot ny mätning | 201, 400 |

`POST /measurements` validerar formatet och kontrollerar att `deviceId` tillhör
en känd sensor innan mätningen sparas. Okänd sensor eller ogiltigt format ger
400 med ett JSON-fel som beskriver vad som var fel.

`GET /devices/{id}/latest` läser först från Redis. Vid cache miss hämtas värdet
från PostgreSQL och skrivs till cachen. Känd sensor utan mätningar ger 404,
liksom okänd sensor — med olika felmeddelanden.

## Tester

```bash
docker compose exec api python -m pytest -q
```

Sex tester som verifierar valideringslogiken i `api/validation.py`.

## SQL-frågor

De tre obligatoriska frågorna finns i
[database/queries.sql](database/queries.sql): totalt antal mätningar, medel-
temperatur och mätningar från de senaste 24 timmarna.

Kör dem i psql:

```bash
docker compose exec db psql -U student -d jensen_iot
```

## CI

GitHub Actions kör testsviten vid varje push. Se
[.github/workflows/ci.yml](.github/workflows/ci.yml).

## Kubernetes (Minikube)

Endast API:t distribueras. PostgreSQL, Redis och simulatorn körs i Compose.

```bash
minikube start --driver=docker
minikube image build -t jensen-iot-api:lab ./api
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
minikube service jensen-iot-api --url
```

**Self-healing:** `kubectl delete pod <namn>` — Deploymenten skapar automatiskt
en ersättare så att antalet återgår till tre.

**Scaling:** `kubectl scale deployment jensen-iot-api --replicas=5`

## Teknik

Python 3.12, Flask 3.1, PostgreSQL 16, Redis 7, Docker Compose, GitHub Actions,
Kubernetes (Minikube)