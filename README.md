# Agentic App with NVIDIA NIM and EKS

---

# 🧠⚡ NIMbleMind
### *Agentic Intelligence, Deployed at Cloud Speed*

[![AWS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazon-aws&logoColor=white)]()
[![NVIDIA NIM](https://img.shields.io/badge/NVIDIA-NIM-76B900?logo=nvidia&logoColor=white)]()
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?logo=terraform&logoColor=white)]()
[![LangGraph](https://img.shields.io/badge/LangGraph-Agentic%20Orchestration-blueviolet)]()
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python&logoColor=white)]()
[![React](https://img.shields.io/badge/Frontend-React-61DAFB?logo=react&logoColor=white)]()
[![VS Code](https://img.shields.io/badge/Dev-Container-blue?logo=visual-studio-code&logoColor=white)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

---

## 🏎️ Overview
**NIMbleMind** is a full-stack **Agentic AI application** built for the 2025 NVIDIA × AWS × TRD Hackathon.  
It showcases how **Llama-3.1 Nemotron-Nano 8B v1** (deployed as a NVIDIA NIM inference microservice) can power an **agentic reasoning system** hosted efficiently on **AWS EKS**, paired with a **Retrieval Embedding NIM** for contextual memory.

> 🪶 *NIMbleMind combines scalable cloud deployment with modular agentic reasoning — making intelligence fast, composable, and cloud-native.*

---

## 🧩 Core Stack

| Layer | Technology | Purpose |
|-------|-------------|----------|
| **Inference** | `NVIDIA NIM: Llama-3.1-Nemotron-Nano-8B-v1` | Large-language reasoning engine |
| **Embedding / Retrieval** | `NVIDIA nv-embedqa-e5-v5` | Vector memory for contextual recall |
| **Compute Platform** | `AWS EKS` (Terraform provisioned) | Containerized microservice orchestration |
| **Monitoring / Logging** | `CloudWatch + Cost Explorer` | Usage tracking + cost alerts |
| **Backend (Agentic Layer)** | `Python 3.12 + LangGraph + FastAPI` | Reasoning graph / API endpoint |
| **Frontend (UI)** | `React + ShadCN UI` | Interactive visualization & agent control |
| **IaC** | `Terraform Modules + AWS IAM Roles` | Automated, reproducible infra setup |
| **Dev Environment** | `VS Code Dev Container` | Standardized local + CI/CD build |

---

## 🚀 Features

- ⚙️ **Agentic AI Core** – Modular reasoning agents coordinated via LangGraph.  
- ☁️ **NVIDIA NIM Inference** – Runs Llama 3.1 Nano 8B as a microservice on EKS.  
- 🧭 **Retrieval Embedding Memory** – Uses nv-embedqa NIM for contextual grounding.  
- 📊 **AWS Native Infra** – Scalable, monitored, cost-controlled Kubernetes cluster.  
- 💬 **React UI Dashboard** – Live prompts, telemetry insights, and cost metrics.  
- 🛠️ **Infrastructure as Code** – Terraform modules for EKS, IAM, VPC, CloudWatch.  
- 🧩 **DevContainer Support** – Ready-to-code environment for reproducible builds.  

---

## 🧱 Repository Structure

```

agentic-app/
├── .devcontainer/
│   ├── Dockerfile
│   └── devcontainer.json
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── eks/
│   ├── iam/
│   ├── vpc/
│   └── alarms/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── agents/
│   │   └── services/
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── api/
│   ├── package.json
│   └── README.md
├── .gitignore
├── README.md
└── LICENSE

````

---

## ⚙️ Quick Start

```bash
# Clone repository
git clone https://github.com/you/nimblemind.git
cd nimblemind

# Set up DevContainer
code .  # Reopen in Container

# Initialize Terraform
cd infra
terraform init
terraform apply

# Deploy backend + frontend pods
kubectl apply -f k8s/

# Launch local dev UI
cd frontend && npm run dev
````

---

## 🧠 Monitoring & Cost Control

* **AWS Cost Explorer + Budgets** → set alert at 50 % of free-tier usage.
* **CloudWatch Metrics** → track pod CPU/GPU utilization and auto-scale triggers.
* **Terraform Lifecycle Hooks** → destroy unused clusters every 3 hours via cron job.
* **Regions** → `us-east-1` or `us-west-2` recommended for lowest EKS pricing.

---

## 🤝 Contribution

Pull requests welcome!
Please follow [CONTRIBUTING.md](CONTRIBUTING.md) and use `feature/*` branch naming.

---

## 📜 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file.

---

## 🌟 Acknowledgments

* 🧠 **NVIDIA AI Enterprise** for NIM microservices
* ☁️ **AWS EKS Team** for scalable Kubernetes infrastructure
* ⚙️ **HashiCorp Terraform** for IaC automation
* 💡 **LangChain / LangGraph** for agentic reasoning frameworks
* 👥 Hackathon 2025 Judges & Mentors for inspiration and feedback

---

> ✨ *Built with purpose, speed, and precision — NIMbleMind makes agentic AI truly cloud-native.*

```

---

Would you like me to append a **short “Deployment Status & Badges” block** (GitHub Actions + ECR build + Cost Monitor badge) under the overview section next?  
That adds live status visuals that impress hackathon judges immediately.
