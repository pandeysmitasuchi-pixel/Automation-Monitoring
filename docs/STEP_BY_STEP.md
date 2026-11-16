[STEP_BY_STEP.md](https://github.com/user-attachments/files/34905936/STEP_BY_STEP.md)
# Step-by-step deployment (Windows + WSL2/Ubuntu recommended)

## Phase 0 — Prepare your workstation

1. Install Git and AWS CLI v2 on Windows. Install WSL2 Ubuntu, then install Terraform, Ansible, Python and OpenSSH inside WSL2. Run Ansible from WSL2 because it is designed for Unix-like control nodes.
2. In Ubuntu/WSL, check `git --version`, `aws --version`, `terraform -version`, `ansible --version`, `ssh -V`.
3. Configure AWS CLI for the assignment region:

   ```bash
   aws configure
   # Default region: ap-south-1
   # Output format: json
   aws sts get-caller-identity
   ```

   Use an IAM identity with the required permissions; never paste credentials into Git or this chat. Capture a screenshot of `get-caller-identity` with account-sensitive values obscured if appropriate for submission.

4. Create an SSH key pair on your WSL/Linux terminal:

   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ssh-keygen -t ed25519 -f ~/.ssh/travelmemory -C travelmemory-assignment
   chmod 600 ~/.ssh/travelmemory
   ```

   Terraform uploads the public key (`~/.ssh/travelmemory.pub`); the private key stays on your machine.

5. Find your current public IPv4 address using a trusted IP-check site and set it as `/32` in `terraform/terraform.tfvars`. Do not use `0.0.0.0/0` for SSH.

## Phase 1 — Terraform: inspect, validate, provision

1. Open the `terraform` directory. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace `my_ip_cidr`. Check the key path matches your WSL key.
2. Review all `.tf` files, particularly CIDRs, IAM, inbound security rules and instance sizes. The configuration uses Ubuntu 22.04 LTS and `ap-south-1`.
3. Run:

   ```bash
   cd terraform
   terraform fmt -recursive
   terraform init
   terraform validate
   terraform plan -out=tfplan
   ```

4. Inspect the plan. Verify two EC2 instances, VPC, two subnets, IGW, NAT Gateway/EIP, route tables, security groups, IAM role/profile, and key pair. If anything is unexpected, stop and fix it.
5. Apply exactly the reviewed plan:

   ```bash
   terraform apply tfplan
   terraform output
   ```

6. Record `web_public_ip`, `web_private_ip`, and `db_private_ip`. Capture screenshots of init, validate, plan, apply/output, VPC/subnets/routes/NAT, EC2 instances and security groups. Do not commit `tfplan`, state, or tfvars.

> Cost note: NAT Gateway is billed hourly and by data processed. Do not leave it running overnight or after evidence capture. Confirm current AWS pricing for your region before applying.

## Phase 2 — Configure Ansible inventory and secrets

1. From repository root, copy `ansible/inventory/hosts.ini.example` to `ansible/inventory/hosts.ini`. Fill in the Terraform outputs. Keep the private key path as `~/.ssh/travelmemory`.
2. Verify the web host can be reached:

   ```bash
   ssh -i ~/.ssh/travelmemory ubuntu@WEB_PUBLIC_IP
   ```

3. Verify the DB host through the web jump host:

   ```bash
   ssh -i ~/.ssh/travelmemory -J ubuntu@WEB_PUBLIC_IP ubuntu@DB_PRIVATE_IP
   ```

4. Install required Ansible collection and create an encrypted vault file:

   ```bash
   ansible-galaxy collection install community.general
   cp ansible/group_vars/all.vault.example.yml ansible/group_vars/vault.yml
   ansible-vault encrypt ansible/group_vars/vault.yml
   ```

   Edit encrypted values with `ansible-vault edit ansible/group_vars/vault.yml`. Use strong, unique passwords. The `vault.yml` path is ignored by Git.

5. Add `vars_files: - group_vars/vault.yml` to the relevant plays in `ansible/site.yml` (or add it under `vars_files` for each play). Run with `--ask-vault-pass`; never create or commit a vault password file.
6. Add the private DB IP and public web IP to inventory group variables as shown. Then test:

   ```bash
   cd ansible
   ansible all -m ping
   ```

   Both web and db must return `SUCCESS`. If the DB fails, check `ProxyJump`, the web SSH rule and DB SG source rules.

## Phase 3 — Run Ansible and deploy

1. Before applying, check `ansible/site.yml` and role variables. The MongoDB role targets Ubuntu 22.04/Jammy and MongoDB 7.0. The web role expects the upstream repository's `frontend/` and `backend/` folders.
2. Run a syntax check and playbook:

   ```bash
   ansible-playbook site.yml --syntax-check
   ansible-playbook site.yml --ask-vault-pass
   ```

3. Inspect any errors; do not blindly rerun failed tasks. Some initial MongoDB user creation commands can report an error if users already exist; verify and adjust idempotence if your first run was interrupted. Run the playbook again after a successful first run and investigate unexpected changes.
4. When successful, browse to `http://WEB_PUBLIC_IP`. If the page stays on Loading, inspect `REACT_APP_BACKEND_URL` and confirm the React build was run after setting it. This template builds the frontend with `http://WEB_PUBLIC_IP` and proxies `/trip` and `/hello` through Nginx to port 3001.

## Phase 4 — Verify required outcomes

Run and capture evidence for:

```bash
# On web server
sudo systemctl status travelmemory-backend --no-pager
sudo systemctl status nginx --no-pager
curl -i http://localhost/hello
curl -i http://localhost/trip

# On DB server (through SSH jump host)
sudo systemctl status mongod --no-pager
mongosh --quiet --eval 'db.runCommand({connectionStatus:1})'
```

- Add a trip through the web form and confirm it appears in the list.
- Authenticate to MongoDB and verify the new document in the app database. Do not put passwords in screenshots.
- Confirm laptop cannot connect directly to DB private IP (it has no public IP) and no security group exposes 27017 publicly.
- Confirm API port 3001 is not publicly open; API is accessed through Nginx on port 80.
- Check SSH password/root login settings without locking yourself out. Keep the current session open while testing a second session.
- Run the playbook a second time and capture output showing no unexpected changes. Some package/cache tasks may still report changes; document them honestly.

## Phase 5 — GitHub upload

1. From repository root, review `git status --ignored` and ensure these are not tracked: `.pem`, private keys, `terraform.tfstate*`, `tfplan`, `terraform.tfvars`, `.env`, `vault.yml`, vault password files.
2. Create a new empty public repository on GitHub (do not add an auto-generated README if you already have one here).
3. Run:

   ```bash
   git init
   git add .
   git status --short
   git commit -m "Add Terraform and Ansible TravelMemory deployment"
   git branch -M main
   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY.git
   git push -u origin main
   ```

4. Open the repository URL in a private/incognito browser window to ensure it is public. Put the URL in your final report/submission text file.

## Phase 6 — Destroy AWS resources after evidence capture

From `terraform/`:

```bash
terraform plan -destroy
terraform destroy
```

Confirm the destroy prompt only after reviewing resources. Capture the successful destroy output. Verify in AWS that the NAT Gateway, Elastic IP, EC2 instances and other created resources are gone. Keep the code in GitHub; Terraform destroy removes cloud infrastructure, not repository files.
