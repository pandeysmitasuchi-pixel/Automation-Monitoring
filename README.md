# TravelMemory on AWS — Terraform + Ansible

Assignment implementation for deploying the supplied [TravelMemory MERN app](https://github.com/UnpredictablePrashant/TravelMemory) to AWS in `ap-south-1` (Mumbai).

> **Important:** This repository is an infrastructure/configuration code starter, not proof that AWS deployment has already run. You must run the commands in your own AWS account, verify each stage, and add your genuine screenshots to `evidence/` before submission.

## Target architecture

- VPC `10.0.0.0/16`
- Public subnet: web EC2 (Nginx + React production build + Node/Express API), public IPv4
- Public subnet: NAT Gateway + Elastic IP
- Private subnet: MongoDB EC2, no public IPv4
- Public default route → Internet Gateway; private default route → NAT Gateway
- Web SG: SSH only from your public IP `/32`, HTTP/HTTPS from the internet; no public API port
- DB SG: SSH and MongoDB only from the web security group
- Ansible configures both machines; DB is reached via the web host as a jump host

## Repository layout

```text
terraform/                 AWS VPC, routes, security groups, IAM, EC2
ansible/                   Inventory, vault example, playbooks and roles
docs/                      Architecture and evidence checklist
evidence/                  Add real screenshots here (do not fabricate)
.gitignore                 Excludes state, secrets, keys, .env and generated files
```

## Before you start

1. Have an AWS account with permission to create VPC, EC2, IAM, Elastic IP and NAT Gateway resources.
2. Install AWS CLI v2, Terraform >= 1.6, Ansible, Git, and OpenSSH on your computer. Ansible is easiest in WSL2/Ubuntu on Windows.
3. Review AWS charges. **NAT Gateways, EC2 instances, EBS volumes and public IPv4 addresses can cost money.** Destroy resources after collecting evidence.
4. Never commit AWS credentials, private keys, Terraform state, `.env`, Ansible Vault passwords, or real passwords.

## Deployment sequence

Follow `docs/STEP_BY_STEP.md` from top to bottom. Do not run `terraform apply` until you have inspected the plan and confirmed the AWS region, instance types, SSH CIDR, and expected costs.

## Application notes

The assignment repository uses `REACT_APP_BACKEND_URL` in the frontend build and `MONGO_URI` plus `PORT=3001` for the backend. The frontend variable must be set **before** `npm run build`. Nginx serves the React build and proxies `/trip` and `/hello` to the API on `127.0.0.1:3001`. Port 3001 is not opened in the security group.

## Evidence required

See `docs/STEP_BY_STEP.md` and `docs/REPORT_TEMPLATE.md`. Use actual screenshots from your run. Include AWS identity, Terraform init/plan/apply, network resources, both EC2 instances and security groups, Ansible ping and playbook, MongoDB auth, backend/Nginx status, app and add-trip test, DB record, hardening checks, and `terraform destroy`.
