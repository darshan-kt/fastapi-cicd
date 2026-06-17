# CI/CD Interview Questions & Answers

## FastAPI + Docker + DockerHub + GitHub Actions Edition

This document covers the fundamental CI concepts every DevOps Engineer, Platform Engineer, or Backend Engineer should understand.

---

# 1. What problem does CI solve?

## Answer

Continuous Integration (CI) solves the problem of integrating code changes safely and frequently.

Before CI:

* Developers manually merged code.
* Bugs were discovered late.
* Deployments were risky.

CI automatically:

* Builds code
* Runs tests
* Checks code quality
* Detects issues early

CI reduces integration risk and provides fast feedback.

---

# 2. Why should CI runners be ephemeral?

## Answer

CI runners should be ephemeral because every pipeline execution must start from a clean environment.

An ephemeral runner:

```text
Create VM
→ Run pipeline
→ Destroy VM
```

Benefits:

* Prevents state leakage
* Ensures consistency
* Improves security
* Avoids hidden dependencies

If a build only works because of cached files from a previous run, the build is not reliable.

---

# 3. Why must builds be reproducible?

## Answer

A reproducible build produces the same result every time using the same source code and dependencies.

Without reproducibility:

```text
Works on developer laptop
Fails in CI
Fails in production
```

Techniques:

* Pin dependency versions
* Use Docker
* Use lock files
* Build immutable artifacts

Reproducibility eliminates uncertainty.

---

# 4. What is the difference between linting and testing?

## Answer

### Linting

Checks code quality and style.

Examples:

* Unused imports
* Syntax issues
* Formatting violations

Tool:

```text
Ruff
```

### Testing

Verifies application behavior.

Examples:

* API response validation
* Business logic checks
* Error handling

Tool:

```text
Pytest
```

Linting checks code structure.

Testing checks code correctness.

---

# 5. Why is code coverage important?

## Answer

Code coverage measures how much of the codebase is executed during tests.

Example:

```text
Coverage = 85%
```

Higher coverage means:

* Better confidence
* Lower risk of regressions

However:

```text
100% coverage ≠ bug-free software
```

Focus on meaningful tests rather than coverage percentage alone.

---

# 6. What is SAST?

## Answer

SAST stands for:

```text
Static Application Security Testing
```

It analyzes source code without executing it.

SAST detects:

* Hardcoded secrets
* Dangerous functions
* Security vulnerabilities

Examples:

* Bandit
* Semgrep
* SonarQube

Security should shift left into CI pipelines.

---

# 7. Why do we build Docker images in CI?

## Answer

Docker images are built in CI to create consistent and deployable artifacts.

Benefits:

* Same artifact in every environment
* Easier deployments
* Immutable releases

Flow:

```text
Code
→ CI
→ Docker Image
→ Deploy
```

This guarantees that production runs exactly what CI tested.

---

# 8. Why push images to DockerHub?

## Answer

DockerHub acts as a container registry.

Benefits:

* Central image repository
* Version control
* Easy deployment
* Team collaboration

Deployment platforms pull images directly:

```text
Kubernetes
→ DockerHub
→ Pull image
```

Container registries are artifact repositories for containers.

---

# 9. What causes "works on my machine" problems?

## Answer

These problems occur when local environments differ from CI or production.

Common causes:

* Different Python versions
* Missing dependencies
* Environment variables
* Local IDE settings
* Hidden configurations

Solutions:

* Docker
* CI pipelines
* Dependency pinning

The goal:

```text
Developer = CI = Production
```

---

# 10. Why should tests run before Docker builds?

## Answer

Tests should run first because building Docker images consumes time and resources.

Pipeline order:

```text
Lint
→ Test
→ Build
→ Publish
```

Benefits:

* Fail fast
* Save CI minutes
* Reduce wasted builds

Never build artifacts for broken code.

---

# 11. Why use immutable container images?

## Answer

Immutable images never change after creation.

Example:

```text
fastapi:v1.0.0
```

Never modify:

```text
v1.0.0
```

Instead create:

```text
v1.0.1
```

Benefits:

* Easier rollbacks
* Better traceability
* Predictable deployments

Immutability is a core DevOps principle.

---

# 12. What is the purpose of GitHub Secrets?

## Answer

GitHub Secrets securely store sensitive information.

Examples:

* DockerHub tokens
* AWS credentials
* API keys

Example:

```yaml
${{ secrets.DOCKERHUB_TOKEN }}
```

Secrets prevent credentials from being stored in source code.

Never commit secrets to Git.

---

# 13. How would you debug a failing CI pipeline?

## Answer

Debugging approach:

1. Identify failed stage
2. Read logs carefully
3. Reproduce locally
4. Compare environments
5. Fix root cause
6. Re-run pipeline

Common commands:

```bash
pytest -vv -s

docker logs <container-id>

pip freeze

python --version
```

Golden rule:

```text
Read the first error, not the last one.
```

---

# 14. Why use PYTHONPATH?

## Answer

PYTHONPATH tells Python where to search for modules.

Example:

```yaml
env:
  PYTHONPATH: .
```

This adds the repository root to Python's module search path.

Use cases:

* CI environments
* Monorepos
* Non-standard layouts

Prefer proper package structure (`__init__.py`) whenever possible.

---

# 15. Why should every merge trigger CI?

## Answer

Every merge changes the codebase.

Without CI:

* Bugs reach production
* Broken integrations remain unnoticed
* Technical debt grows

CI ensures:

```text
Merge
→ Validate
→ Build
→ Publish
```

Every merge is a potential release candidate.

Therefore every merge should be validated automatically.

---

# Final DevOps Principles

## Principle 1

If it is manual, automate it.

## Principle 2

If it cannot be reproduced, it cannot be trusted.

## Principle 3

If it cannot be tested, it should not be deployed.

## Principle 4

Build once. Deploy many times.

## Principle 5

Treat infrastructure like software.

---

# CI Pipeline Summary

```text
Developer
    |
git push
    |
GitHub
    |
GitHub Actions
    |
+-----------------------+
| Lint                  |
| Unit Tests            |
| Coverage              |
| Security Scan         |
| Docker Build          |
| Docker Push           |
+-----------------------+
    |
DockerHub
    |
Deployment Platform
```
