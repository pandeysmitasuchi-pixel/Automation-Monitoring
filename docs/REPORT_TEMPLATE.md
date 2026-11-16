[REPORT_TEMPLATE.md](https://github.com/user-attachments/files/34905914/REPORT_TEMPLATE.md)
# Project Report — Deploying TravelMemory on AWS with Terraform and Ansible

**Student:** [Your name]  
**Course / batch:** [Course]  
**GitHub repository:** [Public repository URL]  
**AWS region:** ap-south-1 (Mumbai)

## 1. Objective
Provision AWS infrastructure with Terraform and configure/deploy the supplied TravelMemory MERN application using Ansible, without manually configuring servers in the AWS console.

## 2. Architecture
Describe the VPC (`10.0.0.0/16`), public web subnet, private DB subnet, IGW, NAT Gateway, route tables, security groups, IAM instance profile, web EC2 and DB EC2. Insert your architecture diagram and explain traffic flow.

## 3. Tools
AWS CLI, Terraform, Ansible, Git, Ubuntu 22.04, Node.js, React, Express, MongoDB, Nginx.

## 4. Terraform implementation
Summarize files and resources. Explain the public/private routes, NAT Gateway, SSH `/32`, DB security group referencing the web security group, IMDSv2 and encrypted EBS. Insert genuine screenshots: AWS identity, `terraform init`, validate, plan, apply/output, VPC/subnets/routes/gateways/EC2/SGs.

## 5. Ansible implementation
Explain inventory and jump-host access, common/hardening/MongoDB/webserver roles, Ansible Vault, MongoDB authorization and least-privilege app user, systemd backend service, React production build, and Nginx proxy. Insert genuine screenshots of ping and playbook output.

## 6. Validation and results
- [ ] Website opens at public IP
- [ ] `/hello` API route responds through Nginx
- [ ] Trips load from MongoDB
- [ ] New trip appears after submission
- [ ] MongoDB record verified with authentication
- [ ] DB has no public IP and port 27017 is not internet-exposed
- [ ] Backend port 3001 is not internet-exposed
- [ ] Root/password SSH login disabled and verified safely
- [ ] Second Ansible run checked for idempotence

Insert genuine screenshots of MongoDB, systemd backend, Nginx, browser/add-trip, DB record, hardening and rerun.

## 7. Challenges and resolutions
Document actual errors, their causes, and how you resolved them. Do not claim tests that you did not perform.

## 8. Cost control and cleanup
State when `terraform destroy` was run and include its output screenshot. Mention that NAT Gateway, EC2 and public IPv4 resources can incur charges.

## 9. Conclusion
Summarize what was automated and what you verified.
