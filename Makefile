SHELL:=/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# Environment setup and management
# ---------------------------------------------------------------------------------------------------------------------
virtualenv:
	python3 -m venv ./venv && source venv/bin/activate
setup-env: virtualenv
	python3 -m pip install -r requirements.txt
# ---------------------------------------------------------------------------------------------------------------------
# Running the app
# ---------------------------------------------------------------------------------------------------------------------
run:
	python -m gunicorn -b 0.0.0.0:4000 --workers=4 flask_app.app:app
build:
	docker-compose build
up:
	docker-compose up -d
build-up:
	docker-compose up -d --build
down:
	docker-compose down
build-latest:
	docker build -t insecureapps/broken-flask:latest .
pull-backend-latest:
	docker pull insecureapps/broken-flask-employees:latest
# ---------------------------------------------------------------------------------------------------------------------
# SAST
# ---------------------------------------------------------------------------------------------------------------------
semgrep:
	@echo "Running Semgrep"
	@semgrep --config=r/all ./flask_app
bandit:
	@echo "Running Bandit"
	@bandit -r ./flask_app
# ---------------------------------------------------------------------------------------------------------------------
# Dependency scanning
# ---------------------------------------------------------------------------------------------------------------------
snyk:
	@echo "Running Snyk for dependency scanning"
	@snyk code test
# ---------------------------------------------------------------------------------------------------------------------
# Infrastructure as code scanning
# ---------------------------------------------------------------------------------------------------------------------
tf-semgrep:
	@semgrep --config=r/all ./terraform
tfsec:
	@tfsec ./terraform
checkov:
	@echo "Running Checkov for Infrastructure as code"
	@checkov --quiet --directory ./terraform
# ---------------------------------------------------------------------------------------------------------------------
# DAST OSS
# ---------------------------------------------------------------------------------------------------------------------
zap:
	@echo "Running OWASP ZAP"
	# TODO: Figure out the right command. This isn't working.
	@docker run -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py -t https://flask.brokenlol.com
# ---------------------------------------------------------------------------------------------------------------------
# NightVision DAST - local
# ---------------------------------------------------------------------------------------------------------------------
nv-create-local:
	nightvision app create -n broken-flask-local
	nightvision target create -n broken-flask-local -a broken-flask-local --url http://localhost:4000 --type api
nv-swagger-local:
	nightvision swagger extract -t broken-flask-local -o files/nv-generated-spec.yml -l python ./flask_app
nv-scan-local:
	@echo "Running NightVision"
	nightvision scan broken-flask-local

# ---------------------------------------------------------------------------------------------------------------------
# NightVision DAST - AWS
# ---------------------------------------------------------------------------------------------------------------------
nv-create-aws:
	nightvision app create -n broken-flask-aws
	nightvision target create broken-flask-aws --url https://flask.brokenlol.com --type api
nv-swagger-aws:
	nightvision swagger extract -t broken-flask-aws -o files/nv-generated-spec.yml -l python ./flask_app
nv-scan-aws:
	@echo "Running NightVision"
	nightvision scan broken-flask-aws
