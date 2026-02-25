# Linux Server Hardener

A beginner-friendly, idempotent Bash script that applies essential security hardening to a fresh Ubuntu server (tested in WSL2 / Ubuntu 22.04–24.04).

**Project #1** in my 50-project DevOps learning journey  
→ from Linux basics → Docker → LocalStack AWS simulation → Terraform → Kubernetes → GitOps → observability stack

## What this script does

- Updates & patches the system + enables unattended security upgrades
- Creates a non-root sudo user (`devopsadmin`)
- Locks the root account (no direct login)
- Hardens SSH:
  - Switches to non-standard port (2222)
  - Disables password authentication (key-only)
  - Disables root login over SSH
  - Adds client alive interval to close idle sessions
- Logs actions to `/var/log/harden.log`
- Designed to be **safe to run multiple times** (idempotent checks)

## Concepts you learn / demonstrate

- Principle of Least Privilege (no root daily usage)
- Defense in depth (layered controls: patching + user isolation + access restrictions)
- Idempotency (repeatable automation – core DevOps principle)
- Bash scripting basics (variables, conditionals, file editing with sed, service management)
- SSH key-based authentication workflow
- Server hardening mindset (preparation for cloud instances, CIS benchmarks, audit trails)

## Prerequisites

- Ubuntu 22.04 / 24.04 (WSL2, VM, VPS, cloud instance)
- Initial sudo/root access
- SSH key pair already generated (`ssh-keygen -t ed25519`)
- Public key must be accessible/copiable to the new user before disabling password auth

## Usage

```bash
# 1. Clone & enter directory (as your initial user)
git clone https://github.com/YOUR_GITHUB_USERNAME/linux-server-hardener.git
cd linux-server-hardener

# 2. Make executable
chmod +x harden.sh

# 3. (Critical) Make sure you can log in with keys as devopsadmin BEFORE disabling passwords
#    Test: ssh devopsadmin@localhost

# 4. Run the hardening (may ask for sudo password once)
sudo ./harden.sh

# 5. After run → test new SSH connection
ssh -p 2222 devopsadmin@localhost
# or from remote: ssh -p 2222 devopsadmin@your-server-ip
