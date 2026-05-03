# 🚀 Intelligent Cross-Repository CI Optimization System using Impact-Based Test Selection

## 📌 Overview

Modern CI pipelines often execute full regression test suites even when code changes are small and localized. This leads to unnecessary compute cost, slower feedback loops, and reduced engineering efficiency—especially in microservice architectures with multiple repositories.

This project introduces an Impact-Based Test Selection System that dynamically executes only the tests affected by a code change by analyzing Git diffs across repositories and mapping them to relevant test tags.

Instead of running full regression suites, the system intelligently selects and executes only impacted Karate tests, while ensuring baseline coverage through a safe fallback mechanism.

---

### 🧠 Key Idea

Reduce CI execution time by transforming Git changes into targeted test execution plans using deterministic impact mapping.

---

### ⚙️ Core Capabilities
- 🔁 Cross-repository CI orchestration using GitHub Repository Dispatch
- 🔍 Git diff analysis using JGit for file-level change detection
- 🧠 Rule-based impact mapping (code → test tags)
- 🧪 Dynamic Karate test selection at runtime
- 🛡️ Safe fallback mechanism using @smoke tests
- 📊 Execution metrics for CI performance tracking

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

Safe Fallback

If no impacted tests are detected:

```text
bash

@smoke
```

## 📈 Metrics Output

### File:

metrics.json

### Example:

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
- ⏱ Observed up to 60–70% reduction in controlled scenarios
- 💰 Reduced CI cost
- 🚀 Faster feedback loop for developers
- 🔁 Reduced redundant test execution
- 🧪 Maintained regression safety via fallback coverage
- 🔗 Cross-repository orchestration

## 📌 Why This Matters

In large-scale systems with multiple services and repositories, CI pipelines become a major bottleneck. Running full regression suites for every change leads to:

- High infrastructure cost
- Slow developer feedback cycles
- Inefficient resource utilization

This system demonstrates a practical approach to impact-aware CI execution without requiring complex dependency graphs or external SaaS tooling.

##  👨‍💻 Author

Designed and implemented a cross-repository DevOps intelligence framework that enables impact-based test selection, reducing full regression execution by dynamically running only affected Karate tests based on Git diff analysis.
