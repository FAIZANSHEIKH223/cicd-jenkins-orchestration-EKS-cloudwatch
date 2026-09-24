#!/usr/bin/env bash

set -euo pipefail

APPLICATION_DIR="${APPLICATION_DIR:-application-code}"
VENV_DIR="${VENV_DIR:-venv}"

cd "$APPLICATION_DIR"

mkdir -p reports

if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "ERROR: Python virtual environment was not found."
    exit 1
fi

source "$VENV_DIR/bin/activate"

echo "=========================================="
echo "FLAKE8"
echo "=========================================="

flake8 \
    . \
    --exclude=venv,.git,reports,__pycache__ \
    --statistics

echo "=========================================="
echo "PYLINT"
echo "=========================================="

PYTHON_FILES=$(find . \
    -type f \
    -name "*.py" \
    ! -path "./venv/*" \
    ! -path "./.git/*" \
    ! -path "./reports/*")

if [[ -n "$PYTHON_FILES" ]]; then
    pylint \
        $PYTHON_FILES \
        --output-format=text \
        > reports/pylint-report.txt || PYLINT_STATUS=$?
else
    echo "No Python files found."
    PYLINT_STATUS=0
fi

cat reports/pylint-report.txt || true

if [[ "${PYLINT_STATUS:-0}" -ne 0 ]]; then
    echo "Pylint reported issues."
    exit "$PYLINT_STATUS"
fi

echo "=========================================="
echo "PYTEST"
echo "=========================================="

if [[ -d tests ]]; then

    pytest \
        tests \
        -v \
        --junitxml=reports/pytest-results.xml

else

    echo "WARNING: tests directory not found."

    mkdir -p reports

    cat > reports/pytest-results.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="pytest" tests="0" failures="0" errors="0" skipped="0"/>
EOF

fi

echo "=========================================="
echo "QUALITY AND TESTS PASSED"
echo "=========================================="
