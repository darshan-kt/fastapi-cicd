#!/bin/bash
set -e

echo "Linting..."
ruff check .

echo "Testing..."
pytest -v

echo "Coverage..."
coverage run -m pytest
coverage report

echo "Security..."
bandit -r app