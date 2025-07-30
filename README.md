# Linux Server Email Alerts via Gmail SMTP

This guide walks you through setting up your Linux server (e.g., AWS EC2 instance) to send alert emails using Gmail's SMTP—**no custom domain required**. We’ll use the lightweight `msmtp` utility to relay messages through Gmail securely.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Step 1: Generate Your Gmail App Password](#step-1-generate-your-gmail-app-password)
- [Step 2: Install msmtp](#step-2-install-msmtp)
- [Step 3: Configure msmtp for Gmail SMTP](#step-3-configure-msmtp-for-gmail-smtp)
- [Step 4: Install the mail Utility](#step-4-install-the-mail-utility)
- [Step 5: Open Required Ports in AWS Security Group](#step-5-open-required-ports-in-aws-security-group)
- [Step 6: Test Sending an Email](#step-6-test-sending-an-email)
- [Step 7: Using Email in Shell Scripts](#step-7-using-email-in-shell-scripts)
- [Tips \& Security](#tips--security)
- [Troubleshooting](#troubleshooting)


## Overview

With this setup, you can use scripts (like disk usage alerts) to automatically email notifications to your Gmail inbox. This approach works for **personal**, **testing**, or **production** environments where you do not own a domain.

## Requirements

- An AWS EC2 (or any Linux) server
- A Gmail account with 2-Step Verification enabled
- (Optional) A script for sending alerts (e.g., `disk_check.sh`)


## Step 1: Generate Your Gmail App Password

> Gmail requires special “App Passwords” for external mail clients if you use 2FA.

1. Go to your [Google account security page](https://myaccount.google.com/apppasswords).
2. Under "Signing in to Google," select **App Passwords**.
3. Choose **Mail** as the app, and pick a device name (e.g., “LinuxServer”). Click "Generate".
4. Copy the 16-character app password. **Save it securely.**

## Step 2: Install msmtp

**Debian/Ubuntu:**

```bash
sudo apt update
sudo apt install msmtp msmtp-mta
```

**Red Hat/CentOS:**

```bash
sudo yum install msmtp
```


## Step 3: Configure msmtp for Gmail SMTP

1. Create (or edit) the msmtp configuration file:
    - **User config:** `~/.msmtprc`
    - **System-wide:** `/etc/msmtprc` (requires root)
2. Add this configuration:
```ini
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account        gmail
host           smtp.gmail.com
port           587
from           yourname@gmail.com        # <-- your Gmail address
user           yourname@gmail.com        # <-- your Gmail address
password       your_app_password         # <-- app password from Step 1

account default : gmail
```

- Both `from` and `user` must be **identical:** use your actual Gmail email address.
- Replace `your_app_password` with your app password.

3. Set file permissions (VERY IMPORTANT):
```bash
chmod 600 ~/.msmtprc
```


## Step 4: Install the `mail` Utility

Some scripts use `mail` to send messages.

**Debian/Ubuntu:**

```bash
sudo apt install bsd-mailx
```

**Red Hat/CentOS:**

```bash
sudo yum install mailx
```


## Step 5: Open Required Ports in AWS Security Group

Gmail SMTP uses:

- **Port 587 (TLS)**
- **Port 465 (SSL, alternate)**

**In your AWS Security Group:**

- Go to EC2 > Security Groups > Outbound Rules.
- Ensure these are allowed for `0.0.0.0/0`:
    - TCP port 587 (preferred)
    - TCP port 465 (optional)

(AWS blocks port 25 for SMTP by default; do **not** use port 25.)

## Step 6: Test Sending an Email

1. Use the `mail` command to send a test:

```bash
echo "Test message from EC2 via Gmail SMTP" | mail -s "Test Email" yourname@gmail.com
```

2. Check your Gmail inbox (including spam).

> If you use the default `sendmail` or scripts call it, link it to `msmtp`:
> ```bash > sudo ln -sf /usr/bin/msmtp /usr/sbin/sendmail > ```

## Step 7: Using Email in Shell Scripts

Your scripts (like `disk_check.sh`) can call the `mail` command as usual:

```bash
echo "Disk usage is high" | mail -s "Disk Alert" yourname@gmail.com
```

No changes needed—as long as `msmtp` is properly configured, it relays mail through Gmail.

## Tips \& Security

- **Never share or commit your `.msmtprc` file** if it contains passwords. Add it to `.gitignore`.
- Use a dedicated Gmail account or app password—not your primary one.
- Limit EC2 Security Group incoming rules to your admin IP only.


## Troubleshooting

- **No email received?**
    - Run with verbose:
`echo "Hello" | msmtp -v -a gmail yourname@gmail.com`
    - Check logs:
`cat ~/.msmtp.log`
- **Authentication error:**
    - Ensure app password is correct and two-factor authentication is enabled.
- **Check firewall/security groups:**
    - Ensure ports 587/465 are open for egress.
- **Gmail spam:**
    - Sometimes first-time or script-generated emails land in spam; mark them as "Not Spam" in Gmail.


## References

- [Gmail App Passwords](https://myaccount.google.com/apppasswords)
- [msmtp ArchWiki](https://wiki.archlinux.org/title/Msmtp)

**Now your Linux server can send alert emails through Gmail, so you’ll never miss a disk usage warning or critical event—even without a custom domain.**

