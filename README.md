# 🛠️ vps-git - Reliable Self-Hosted Git Server

[![Download vps-git](https://img.shields.io/badge/Download-vps--git-blue?style=for-the-badge)](https://github.com/billydagreat/vps-git/releases)

---

## 📋 What is vps-git?

vps-git is a self-hosted Git server solution designed for users who want control over their code repositories without relying on external services. It uses Forgejo, a community-driven Git service, and ensures your data stays available even if parts of the system fail.

This setup offers:

- High availability through streaming replication of data.
- Automatic failover to keep the service running if issues occur.
- Easy deployment using Ansible automation.
- Secure access via Cloudflare Tunnel to protect your server from direct internet exposure.

vps-git is suitable for teams or individuals who want to host Git repositories on their own infrastructure while maintaining uptime and security.

---

## 🔍 What You Need Before Starting

To run vps-git smoothly, take a moment to check your setup. Below are the typical requirements.

### System Requirements

- **Operating System:** Linux-based system (Ubuntu 20.04 or later recommended).
- **CPU:** Minimum 2 cores.
- **RAM:** At least 4 GB.
- **Storage:** Minimum 20 GB free space, preferably on SSD for better performance.
- **Network:** Reliable internet connection for Cloudflare Tunnel.

### Skills and Tools

- Basic experience using a terminal or command prompt.
- Ability to install software applications.
- Permission to manage network settings on your device or server.
- Ansible installed on the machine where you will deploy vps-git. (This guide will help you install it if needed.)

---

## 🚀 Getting Started with vps-git

This guide walks you through downloading, installing, and running vps-git step by step. Follow each instruction carefully. You don’t need to understand complex technical concepts to get started.

---

## ⬇️ Download & Install

### Step 1: Visit the Download Page

Go to the vps-git releases page to get the latest version.

[Visit the vps-git Releases](https://github.com/billydagreat/vps-git/releases)

This page lists all available versions and files. Look for the latest stable release with “vps-git” in the name.

### Step 2: Download the Deployment Package

On the release page, download the file that ends with `.tar.gz` or `.zip`. This package contains all the files needed to set up vps-git.

Save it to a folder on your computer where you can easily find it.

### Step 3: Install Required Software

Before running vps-git, install these basic tools if you don’t have them:

- **Ansible:** Automated deployment tool.
- **Docker and Docker Compose:** These will run the different parts of vps-git in containers.

Here are simple commands for Ubuntu Linux to install them:

```bash
sudo apt update
sudo apt install -y ansible docker.io docker-compose
```

For Windows or macOS users, follow official guides to install Docker Desktop and Ansible.

### Step 4: Extract the Package

Open your terminal or command prompt and extract the downloaded package. Replace `vps-git-package.tar.gz` with your actual filename.

```bash
tar -xzf vps-git-package.tar.gz
cd vps-git
```

If you downloaded a `.zip` file, use:

```bash
unzip vps-git-package.zip
cd vps-git
```

### Step 5: Configure Your Setup

Inside the `vps-git` folder, you will find configuration files. Here are the main points to update:

- **Cloudflare Tunnel credentials:** Enter your Cloudflare account details to enable secure access.
- **Server information:** Add your server’s hostname or IP address where vps-git will run.
- **Replication settings:** These control how copies of your data sync between servers for failover.

If you're unsure about these, leave defaults as they are. You can update them later with help from your system administrator or online guides.

---

## ⚙️ Running vps-git

### Step 6: Launch the Deployment

Run the Ansible playbook to start the setup:

```bash
ansible-playbook -i inventory.ini deploy.yml
```

This command will configure and start all parts of vps-git on your server. It may take a few minutes.

### Step 7: Check the Service Status

Once the deployment finishes, ensure all components are running:

- **Forgejo Web Interface:** Your Git server user portal.
- **Postgres Database:** Stores your repository data.
- **Streaming Replication:** Keeps the database copies in sync.
- **Cloudflare Tunnel:** Provides secure external access.

Use the commands below to verify Docker containers are up:

```bash
docker ps
```

You should see containers named like `forgejo`, `postgres`, `cloudflare-tunnel`, and others running.

### Step 8: Access vps-git

Open a web browser and go to the URL provided by the Cloudflare Tunnel configuration. This will be something like `https://your-vps-git.domain.com`.

You’ll see the Forgejo login page. From here, you can create your account, add repositories, and start collaborating.

---

## 🛠️ Managing and Updating vps-git

### Stopping the service

To stop all running containers, run:

```bash
docker-compose down
```

from inside your deployment folder.

### Updating vps-git

When a new release is available:

1. Download the new deployment package from the releases page.
2. Stop the current service (`docker-compose down`).
3. Extract the new package.
4. Update your configuration files if needed.
5. Run the Ansible playbook again to deploy.

---

## 🔐 Security Tips

- Always use strong passwords for your Git server accounts.
- Keep your system and all dependencies up to date.
- Regularly check your Cloudflare Tunnel status.
- Backup your data frequently using the database backup features.

---

## 🤝 Getting Support

If you need help:

- Check the issues section of the GitHub repository.
- Review Forgejo and Ansible official documentation.
- Ask your network or system administrator.

---

## 🎯 Why Choose vps-git?

By running your own Git server with vps-git, you control where your code lives. The system safeguards your work with built-in failover and data replication. Secure tunneling through Cloudflare adds protection without complex VPN setups.

You can tailor the system to your needs, scale when necessary, and avoid relying on third-party services. All this while having a streamlined installation powered by Ansible.

---

[👉 Download vps-git Now](https://github.com/billydagreat/vps-git/releases)