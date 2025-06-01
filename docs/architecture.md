# Histoday Architecture

## 🎯 Purpose
Histoday is a historical content publishing system that automatically generates and distributes "100 years ago today" HTML articles. It is designed to run with minimal cost and effort using AWS services.

---

## 🧱 Components

### 1. EC2 Instance (t3.micro)
- Runs a daily cron job
- Executes `fetch_event.py` to:
  - Retrieve historical event data from Wikipedia
  - Render HTML using Jinja2 templates
  - Upload output to S3 static website bucket

### 2. Amazon S3 (Static Website Hosting)
- Stores generated `index.html` files for each date
- Root `index.html` redirects or reflects the latest article
- Public access enabled via bucket policy

### 3. IAM
- EC2 instance has an IAM role allowing `s3:PutObject` and `s3:GetObject` to the designated bucket

### 4. Optional: Amazon CloudFront
- Distributes static website globally with CDN
- Enables SSL for secure HTTPS access

### 5. GitHub
- Stores source code, CloudFormation templates, and Ansible scripts
- Optionally integrated with GitHub Actions for CI/CD

---

## 🛠️ Workflow Diagram

```plaintext
+--------------------+       cron daily
|   EC2 (t3.micro)   |------------------+
| - fetch_event.py   |                  |
+--------------------+                  v
                               +--------------------+
                               |      S3 Bucket     |
                               | - YYYY-MM-DD/      |
                               | - index.html       |
                               +--------------------+
                                        |
                              (optional)|
                                        v
                              +---------------------+
                              |    CloudFront CDN   |
                              | - SSL / Caching     |
                              +---------------------+
```

---

## ⚙️ Daily Execution Flow

1. EC2 cron triggers `fetch_event.py`
2. Python script fetches events for today's date from Wikipedia
3. HTML is rendered using `base.html` template
4. Output is uploaded to S3 under `YYYY-MM-DD/index.html`
5. Root-level `index.html` is updated with the latest version

---

## 📈 Scalability and Cost

- EC2 instance is within free tier (t3.micro or t2.micro)
- S3 usage costs <10 JPY/month for low traffic
- CloudFront is optional unless HTTPS/CDN is required

---

## 🔐 Security Notes

- EC2 instance does not expose a public web interface
- Only S3 is public for read-only access
- IAM role strictly scoped to required S3 actions

---

## ✅ Summary
Histoday separates content generation (EC2) from content delivery (S3), allowing for minimal cost and high availability. It is suitable for automated historical content publishing and can be maintained with minimal operational overhead.
