# 🚀 Cross-Repository Impact-Based Test Selection Framework

## 📌 Overview

This system implements a **cross-repository intelligent test selection framework** that runs only impacted Karate tests based on code changes.

---

## 🏗 Architecture

```text
Dev Repository (fintech-impact-services)
        │
        │ Push Event
        ▼
GitHub Repository Dispatch
        ▼
Automation Repository (karate-change-impact-test)
        │
        ├── Start Spring Boot App in CI
        ├── Wait for API readiness (log + HTTP check)
        ├── Call Impact API (/test-selector)
        ├── JGit-based Impact Analysis
        ├── Generate Test Tags
        ├── Run Karate Tests (tag-based)
        └── Generate Execution Metrics
```

## 🔁 Workflow

### 1. Code Push (Dev Repo)

Trigger:
```text
yaml

on: [push]
```

Dispatch event:
```text
bash

POST /repos/{owner}/karate-change-impact-test/dispatches
{
  "event_type": "dev_push"
}
```
### 2. CI Pipeline Startup (Test Repo)

Steps executed in GitHub Actions:

- Checkout both repositories
- Start Spring Boot application
- Wait for API readiness (log + HTTP check)

### 3. Impact Analysis (Spring Boot Service)

### Endpoint:

```text

HTTP GET /api/dev-ops/test-selector?targetBranch=main~1
```

### Logic:

- Uses JGit diff analysis
- Maps changed files → test tags

## 📊 Mapping Rules

| Change Type     | Test Tag      |
|----------------|--------------|
| /payments/     | @payments     |
| /transactions/ | @transactions |
| /transfer/     | @transfers    |
| /auth/         | @regression   |
| pom.xml        | @regression   |
| No match       | @smoke        |

## 🧪 Test Execution

```bash
mvn test -Dkarate.options="--tags @payments,@transactions"
```

Fallback:

```text
bash

@smoke
```

## 📈 Metrics Output

File:

metrics.json

Example:

```text
json

{
  "impacted_tags": "@payments,@transactions",
  "scenarios_executed": 6,
  "scenarios_skipped": 12,
  "test_reduction_rate": "66%",
  "timing_metrics": {
    "total_workflow_seconds": 52,
    "isolated_test_seconds": 18,
    "api_overhead_seconds": 6
  }
}
```

## 🧪 Karate Test Structure

```text

features/
 ├── payments.feature
 ├── transactions.feature
 ├── transfers.feature
 └── smoke.feature
```

## ⚙️ Setup Guide

Prerequisites
Java 17
Maven
GitHub Actions enabled

## GitHub Secrets
KARATE_REPO_PAT

## 🚀 Run Locally

Start Spring Boot service:

```text

bash

mvn spring-boot:run

```

Call API:

```text
bash

curl http://localhost:8080/api/dev-ops/test-selector

```

Run tests:

```text
bash

mvn test -Dkarate.options="--tags @smoke"

```

## 📊 Key Benefits
- ⏱ 60–70% reduction in test execution time
- 💰 Reduced CI cost
- 🧠 Intelligent impact-based test selection
- 🔗 Cross-repository orchestration

##  👨‍💻 Author

Designed and implemented a cross-repository DevOps intelligence framework that enables impact-based test selection, reducing full regression execution by dynamically running only affected Karate tests based on Git diff analysis.
