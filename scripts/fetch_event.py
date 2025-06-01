import os
import datetime
import requests
from jinja2 import Environment, FileSystemLoader
import boto3
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

# Load .env variables
load_dotenv()

BASE_DIR = "/opt/histoday/public_html"
DATE = datetime.datetime.utcnow() - datetime.timedelta(days=365 * 100)
DATE_STR = DATE.strftime("%Y-%m-%d")
ARTICLE_DIR = os.path.join(BASE_DIR, DATE_STR)
INDEX_FILE = os.path.join(BASE_DIR, "index.html")
BUCKET_NAME = os.getenv("HISTODAY_BUCKET")
EMAIL_RECIPIENTS = os.getenv("EMAIL_RECIPIENTS", "").split(",")
GMAIL_USER = os.getenv("GMAIL_USER")
GMAIL_PASS = os.getenv("GMAIL_PASS")

# Create output directory
os.makedirs(ARTICLE_DIR, exist_ok=True)

# Fetch event text (mocked)
response = requests.get(f"https://en.wikipedia.org/api/rest_v1/feed/featured/{DATE_STR}")
event = response.json().get("onthisday", [{}])[0].get("text", f"Example event on {DATE_STR}")

# Load template and render
env = Environment(loader=FileSystemLoader("templates"))
template = env.get_template("base.html")
html = template.render(date=DATE_STR, event=event)

# Write daily article
article_path = os.path.join(ARTICLE_DIR, "index.html")
with open(article_path, "w") as f:
    f.write(html)

# Rebuild main index.html as a landing page
links = []
for name in sorted(os.listdir(BASE_DIR)):
    fullpath = os.path.join(BASE_DIR, name)
    if os.path.isdir(fullpath) and name.count("-") == 2:
        links.append(f'<li><a href="{name}/">{name}</a></li>')

index_html = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Histoday Index</title>
    <style>
        body {{ font-family: sans-serif; padding: 2em; }}
        h1 {{ color: #2c3e50; }}
        ul {{ line-height: 1.6; }}
    </style>
</head>
<body>
<h1>Histoday: 100 Years Ago</h1>
<ul>
{chr(10).join(links)}
</ul>
</body>
</html>
"""

with open(INDEX_FILE, "w") as f:
    f.write(index_html)

# Upload to S3
if BUCKET_NAME:
    s3 = boto3.client("s3")
    s3.upload_file(article_path, BUCKET_NAME, f"{DATE_STR}/index.html", ExtraArgs={"ContentType": "text/html"})
    s3.upload_file(INDEX_FILE, BUCKET_NAME, "index.html", ExtraArgs={"ContentType": "text/html"})
    print(f"Uploaded to s3://{BUCKET_NAME}/{DATE_STR}/index.html and index.html")

# Send email via Gmail SMTP
if EMAIL_RECIPIENTS and event and GMAIL_USER and GMAIL_PASS:
    subject = f"Histoday: {DATE_STR}"
    body = f"Here is what happened 100 years ago on {DATE_STR}:\n\n{event}\n\nhttps://{BUCKET_NAME}.s3.amazonaws.com/{DATE_STR}/"
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = GMAIL_USER
    msg['To'] = ", ".join(EMAIL_RECIPIENTS)
    msg.attach(MIMEText(body, 'plain'))

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(GMAIL_USER, GMAIL_PASS)
            server.send_message(msg)
        print("Email sent successfully via Gmail.")
    except Exception as e:
        print(f"Failed to send email via Gmail: {e}")

print(f"Generated article for {DATE_STR} and updated index.html")
