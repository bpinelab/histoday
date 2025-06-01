# Makefile for Histoday Automation

.PHONY: install run lint clean setup docker-build docker-run docker-down deploy destroy test

# Set up virtual environment and install dependencies
install:
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# Run the fetch script locally (uses .env)
run:
	. venv/bin/activate && python scripts/fetch_event.py

# Lint Python code
lint:
	. venv/bin/activate && flake8 scripts/*.py

# Clean generated public_html articles
clean:
	rm -rf public_html/19*

# Setup EC2 with Ansible (assumes you are on EC2)
setup:
	cd ansible && ansible-playbook setup.yml -i localhost,

# Build Docker image
docker-build:
	docker-compose build

# Run the fetch script inside Docker
docker-run:
	docker-compose up

# Stop Docker containers
docker-down:
	docker-compose down

# Deploy CloudFormation stacks
deploy:
	./scripts/deploy.sh

# Destroy CloudFormation stacks
destroy:
	./scripts/destroy.sh

# Run test runner script manually
test:
	chmod +x test_runner.sh && ./test_runner.sh
