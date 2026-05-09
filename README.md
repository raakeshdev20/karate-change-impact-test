# 🚀 Intelligent Cross-Repository CI Optimization System using Impact-Based Test Selection
![Status](https://img.shields.io/badge/status-proof--of--concept-orange)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/SpringBoot-3.x-brightgreen)
![Karate](https://img.shields.io/badge/Karate-API%20Testing-blue)

# ⚡ Problem Statement

Modern CI pipelines often execute full regression suites even when code changes are small and localized.

This causes:
- unnecessary compute cost
- slower feedback loops
- inefficient CI resource usage
- delayed developer productivity

especially in microservice architectures with multiple repositories.

---

# 🧠 Key Idea

Transform Git changes into targeted test execution plans using deterministic impact mapping.

Instead of running full regression suites, the system dynamically executes only impacted Karate tests while maintaining baseline safety coverage through fallback smoke tests.

---

# 📊 Controlled Scenario Results

|Execution Mode | Runtime |
|---|---|
| Full Regression | 52s |
| Impact-Based Execution | 18s |
| Reduction Observed | 66% |

---

# ⚙️ Core Capabilities

- 🔁 Cross-repository CI orchestration using GitHub Repository Dispatch
- 🔍 JGit-based file-level Git diff analysis
- 🧠 Rule-based impact mapping (code → test tags)
- 🧪 Dynamic Karate test selection at runtime
- 🛡️ Safe fallback execution using `@smoke`
- 📊 CI execution metrics generation

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
# 📊 Key Benefits

- ⏱ Demonstrated up to 60–70% CI runtime reduction in controlled scenarios
- 💰 Reduced unnecessary regression execution and CI compute usage
- 🚀 Faster developer feedback cycles through selective test execution
- 🔁 Minimized redundant test runs using deterministic impact mapping
- 🧪 Maintained baseline regression safety using fallback smoke coverage
- 🔗 Enabled cross-repository CI orchestration using GitHub Actions

## 📌 Why This Matters

In large-scale systems with multiple services and repositories, CI pipelines become a major bottleneck. Running full regression suites for every change leads to:

- High infrastructure cost
- Slow developer feedback cycles
- Inefficient resource utilization

This system demonstrates a practical approach to impact-aware CI execution without requiring complex dependency graphs or external SaaS tooling.

##  👨‍💻 Author

Designed and implemented a cross-repository DevOps intelligence framework that enables impact-based test selection, reducing full regression execution by dynamically running only affected Karate tests based on Git diff analysis.
