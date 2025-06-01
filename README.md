# Histoday

**Histoday** is an automated system that collects a historical event from exactly 100 years ago each day, generates a summary article, and publishes it to a static website hosted on Amazon S3. Content generation is handled by an EC2 instance, while S3 serves as the public frontend.

---

## Features
- 🗓️ Daily fetch of a historical event from 100 years ago
- 📰 Article generation in HTML using Jinja2
- 📤 Upload to S3 for static site hosting
- 📧 Optional email delivery to subscribed recipients
- 🧪 Local execution for testing
- ⚙️ Infrastructure-as-Code with CloudFormation & Ansible

---

## Repository Structure

```text
.
├── ansible/                 # Ansible provisioning for EC2 setup
│   └── setup.yml            # Tasks: create venv, install dependencies, set up cron
├── cloudformation/          # CloudFormation templates for IaC
│   ├── ec2.yml              # EC2 instance with IAM role, subnet, security group
│   ├── s3.yml               # S3 bucket for static web hosting
│   └── vpc.yml              # VPC, subnet, IGW, and routing
├── cron/
│   └── histoday-cron        # Crontab definition for daily job
├── docs/
│   └── architecture.md      # System architecture overview and diagram
├── scripts/
│   ├── fetch_event.py       # Main script: fetch + render + upload article and update landing page
│   ├── deploy.sh            # Launch CloudFormation stacks
│   └── destroy.sh           # Tear down CloudFormation stacks
├── templates/
│   └── base.html            # Jinja2 HTML template for article rendering
├── .env.example             # Example env variables (S3 bucket, email targets)
├── .gitignore               # Ignore virtualenv, cache, logs, etc.
├── docker-compose.yml       # Optional local dev stack runner
├── Dockerfile               # Optional local container for script testing
├── Makefile                 # Convenience commands
├── README.md                # Project overview and instructions
├── requirements.txt         # Python dependencies: requests, jinja2
└── test_runner.sh           # Local test runner (calls `fetch_event.py`)
```

---

## Getting Started

### 1. Prerequisites
- AWS CLI configured
- SSH key pair available in AWS (e.g., `my-key`)
- IAM permissions to create EC2, S3, and CloudFormation resources

### 2. Environment Variables
Copy and edit `.env`:
```bash
cp .env.example .env
```
Example:
```dotenv
HISTODAY_BUCKET=histoday-public-123456789012
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_DEFAULT_REGION=ap-northeast-1
EMAIL_RECIPIENTS=your@example.com
GMAIL_USER=your@gmail.com
GMAIL_PASS=your-app-password
```

### 3. Deploy Infrastructure
```bash
make deploy
```

### 4. Teardown Infrastructure
```bash
make destroy
```
Includes confirmation prompt and logs to `destroy.log`.

---

## Local Testing
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
make run
```

---

## Makefile Commands
| Command           | Description                                |
|-------------------|--------------------------------------------|
| `make install`    | Set up Python virtualenv and dependencies  |
| `make run`        | Run the fetch + render + upload process    |
| `make setup`      | Provision EC2 using Ansible                |
| `make docker-run` | Run the script inside Docker               |
| `make deploy`     | Deploy infrastructure using CloudFormation |
| `make destroy`    | Tear down infrastructure via destroy.sh    |
| `make clean`      | Clean output HTML in `public_html/`        |
| `make test`       | Manually test the script using test_runner.sh |

---

## Hosting Architecture
- **EC2 (t3.micro)**: generates content daily via cron
- **Amazon S3**: hosts static website (public-read bucket)
- **CloudFormation**: provisions VPC, EC2, S3 resources
- **Ansible**: installs Python, sets up cron and environment

---

## License
[MIT License](./LICENSE)

---

## Author
[bpinelab](https://github.com/bpinelab)
