SHELL:=/bin/bash


apply:
	terraform apply -auto-approve
destroy:
	terraform destroy -auto-approve
replace-ec2:
	terraform apply -replace="aws_instance.web" -auto-approve