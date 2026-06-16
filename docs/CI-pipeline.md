# Production CI Guide: FastAPI + Docker + DockerHub + GitHub Actions

# 1. Introduction

This guide demonstrates how to build a production-style Continuous Integration (CI) pipeline using:

* FastAPI
* GitHub
* GitHub Actions
* Docker
* DockerHub

The goal is to automatically validate code quality and package applications whenever developers push code to GitHub.

---

# 2. What is Continuous Integration (CI)?

Continuous Integration is the practice of automatically:

* Building code
* Running tests
* Performing security scans
* Packaging applications
* Publishing artifacts

for every code change.

CI ensures that broken code never reaches production.

---

# 3. CI Pipeline Overview

## High-Level Workflow

```text
Developer
    |
    | git push
    v
+----------------+
|    GitHub      |
+----------------+
         |
         | triggers
         v
+------------------------+
| GitHub Actions Runner  |
+------------------------+
| 1. Checkout Code       |
| 2. Install Dependencies|
| 3. Lint Code           |
| 4. Run Tests           |
| 5. Coverage Check      |
| 6. Security Scan       |
| 7. Build Docker Image  |
| 8. Push to DockerHub   |
+------------------------+
         |
         v
+----------------+
|   DockerHub    |
+----------------+
```

---

# 4. CI Architecture Infographic

```text
                    ┌──────────────────┐
                    │   Developer      │
                    │  Writes Code     │
                    └────────┬─────────┘
                             │
                        git push
                             │
                             ▼
                  ┌────────────────────┐
                  │      GitHub        │
                  │ Source Repository  │
                  └────────┬───────────┘
                           │
                   Trigger Workflow
                           │
                           ▼
            ┌─────────────────────────────┐
            │     GitHub Actions CI       │
            │                             │
            │  Checkout Repository        │
            │  Install Dependencies       │
            │  Run Ruff Lint              │
            │  Run Pytest                 │
            │  Coverage Report            │
            │  Bandit Security Scan       │
            │  Docker Build               │
            │  Docker Push                │
            └────────────┬────────────────┘
                         │
                         ▼
               ┌─────────────────┐
               │    DockerHub    │
               │ Container Image │
               └─────────────────┘
```

---

# 5. Project Structure

```text
fastapi-cicd/
│
├── app/
│   ├── __init__.py
│   └── main.py
│
├── tests/
│   └── test_main.py
│
├── requirements.txt
├── requirements-dev.txt
├── Dockerfile
├── .dockerignore
├── ci.sh
│
└── .github/
    └── workflows/
        └── ci.yml
```

---

# 6. FastAPI Application

## app/main.py

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def health():
    return {
        "status": "healthy",
        "service": "fastapi-cicd"
    }
```

Run locally:

```bash
uvicorn app.main:app --reload
```

Test endpoint:

```bash
curl localhost:8000
```

Expected:

```json
{
  "status": "healthy",
  "service": "fastapi-cicd"
}
```

---

# 7. Dependencies

## requirements.txt

```text
fastapi==0.116.1
uvicorn[standard]==0.35.0
```

## requirements-dev.txt

```text
pytest
httpx
coverage
ruff
bandit
```

Install:

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

---

# 8. Unit Testing

## tests/test_main.py

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
```

Execute:

```bash
pytest -v
```

Expected:

```text
1 passed
```

---

# 9. Code Coverage

Measure test coverage:

```bash
coverage run -m pytest
coverage report
```

Target:

* Minimum: 80%
* Recommended: 90%+

---

# 10. Static Analysis (Linting)

Run Ruff:

```bash
ruff check .
```

Fix automatically:

```bash
ruff check . --fix
```

---

# 11. Security Scanning

Run Bandit:

```bash
bandit -r app
```

Purpose:

* Detect insecure code
* Catch dangerous functions
* Improve security posture

---

# 12. Local CI Script

## ci.sh

```bash
#!/bin/bash
set -e

ruff check .

pytest -v

coverage run -m pytest
coverage report

bandit -r app
```

Execute:

```bash
chmod +x ci.sh
./ci.sh
```

This simulates CI locally before pushing code.

---

# 13. Dockerize the Application

## Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build image:

```bash
docker build -t fastapi-cicd .
```

Run container:

```bash
docker run -p 8000:8000 fastapi-cicd
```

Verify:

```bash
curl localhost:8000
```

---

# 14. Push Image to DockerHub

Login:

```bash
docker login
```

Tag image:

```bash
docker tag fastapi-cicd YOUR_USERNAME/fastapi-cicd:v1
```

Push image:

```bash
docker push YOUR_USERNAME/fastapi-cicd:v1
```

---

# 15. GitHub Actions Workflow

## .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches:
      - main

  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    env:
      PYTHONPATH: .

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install Dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Lint
        run: ruff check .

      - name: Test
        run: pytest -v

      - name: Coverage
        run: |
          coverage run -m pytest
          coverage report

      - name: Security Scan
        run: bandit -r app

      - name: Docker Build
        run: docker build -t fastapi-cicd .
```

---

# 16. DockerHub Integration (Optional)

Add GitHub Secrets:

* DOCKERHUB_USERNAME
* DOCKERHUB_TOKEN

Workflow:

```yaml
- name: Login DockerHub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

- name: Build and Push
  uses: docker/build-push-action@v6
  with:
    push: true
    tags: ${{ secrets.DOCKERHUB_USERNAME }}/fastapi-cicd:latest
```

---

# 17. Common CI Failures

## Import Error

```text
ModuleNotFoundError: No module named 'app'
```

Fix:

```bash
touch app/__init__.py
```

or

```yaml
env:
  PYTHONPATH: .
```

---

## Test Failure

Debug:

```bash
pytest -vv -s
```

---

## Missing Dependency

Debug:

```bash
pip list
pip freeze
```

---

## Docker Build Failure

Inspect:

```bash
docker build -t test .
```

---

# 18. End-to-End Execution Flow

```text
Developer
   |
   +--> git push
   |
GitHub
   |
GitHub Actions
   |
   +--> Lint
   +--> Test
   +--> Coverage
   +--> Security
   +--> Docker Build
   +--> Docker Push
   |
DockerHub
```

---

# 19. Fundamental Questions Every Engineer Must Answer

1. What problem does CI solve?
2. Why should CI runners be ephemeral?
3. Why must builds be reproducible?
4. What is the difference between linting and testing?
5. Why is code coverage important?
6. What is SAST?
7. Why do we build Docker images in CI?
8. Why push images to DockerHub?
9. What causes "works on my machine" problems?
10. Why should tests run before Docker builds?
11. Why use immutable container images?
12. What is the purpose of GitHub Secrets?
13. How would you debug a failing CI pipeline?
14. Why use `PYTHONPATH`?
15. Why should every merge trigger CI?

---

# 20. Key Takeaways

A production CI pipeline should:

* Validate code quality
* Run automated tests
* Measure coverage
* Scan for vulnerabilities
* Build immutable artifacts
* Publish Docker images
* Provide fast feedback

If CI is green, deployment becomes safer.

CI builds confidence.
CD delivers value.
