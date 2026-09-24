# CI/CD Jenkins Orchestration

This repository contains the Jenkins CI/CD orchestration for the Practice1 DevOps project.

## Repositories

### Application

https://github.com/FAIZANSHEIKH223/application-code.git

Contains the application source code and Dockerfile.

### Terraform

https://github.com/FAIZANSHEIKH223/terraform-infrastructure.git

Contains AWS infrastructure code.

### CI/CD Orchestration

This repository contains Jenkins pipelines, deployment scripts and Kubernetes manifests.

## Architecture

GitHub
   |
   +----------------------+
   |                      |
   v                      v
application-code   terraform-infrastructure
   |                      |
   |                      v
   |                     AWS
   |                      |
   |              +-------+-------+
   |              |       |       |
   |             VPC     ECR      EKS
   |                      |        |
   |                      |        |
   +---------- Jenkins ---+--------+
                 |
                 v
              Docker
                 |
                 v
                ECR
                 |
                 v
                EKS
                 |
                 v
          Kubernetes Service
                 |
                 v
          AWS Load Balancer
                 |
                 v
           Practice1 App

## Environments

The pipeline supports:

- dev
- qa
- stage
- prod

## Jenkins Credentials

Create the following Jenkins credentials:

### GitHub

ID:

github-creds

Type:

Username with password

Use:

Checking out private GitHub repositories.

### AWS

ID:

aws-creds

Type:

AWS Credentials

Use:

AWS CLI, ECR and EKS operations.

The AWS Credentials Jenkins plugin supports binding AWS credentials to environment variables in a Pipeline.

## Jenkins Tools

The Jenkins agent should have:

- Git
- Python 3.12
- Docker
- AWS CLI
- kubectl
- Terraform

## Main Pipeline

The main pipeline is:

Jenkinsfile

Stages:

1. Clean Workspace
2. Checkout Application Code
3. Checkout Terraform Code
4. Environment Configuration
5. Install Python Dependencies
6. Code Quality and Tests
7. Terraform Init and Plan
8. Terraform Apply
9. Docker Build
10. Push Image to ECR
11. Configure EKS Access
12. Deploy Application to EKS
13. Kubernetes Health Check

## Deployment Flow

### Step 1

Jenkins checks out application-code.

### Step 2

Jenkins creates a Python virtual environment.

### Step 3

Jenkins installs dependencies.

### Step 4

Jenkins runs:

- Flake8
- Pylint
- Pytest

### Step 5

Jenkins checks out terraform-infrastructure.

### Step 6

Terraform creates or updates:

- VPC
- Subnets
- Internet Gateway
- NAT Gateway
- ECR
- EKS
- IAM
- CloudWatch logging

### Step 7

Jenkins builds the Docker image.

Example:

practice1:25

where 25 is the Jenkins BUILD_NUMBER.

### Step 8

Jenkins authenticates with ECR.

### Step 9

Jenkins pushes the image to the environment-specific ECR repository.

Examples:

practice1
practice1-qa
practice1-stage
practice1-prod

### Step 10

Jenkins configures kubectl.

### Step 11

Jenkins applies Kubernetes resources.

### Step 12

Jenkins waits for the Kubernetes deployment rollout.

### Step 13

Jenkins checks:

- Pod status
- Deployment status
- Ready replicas
- Service
- Endpoints
- LoadBalancer hostname

## Kubernetes

Namespace:

practice1

Deployment:

practice1-deployment

Service:

practice1-service

Container port:

8501

Service port:

80

Service type:

LoadBalancer

## Image Tagging

Images are tagged with the Jenkins build number.

Example:

123456789012.dkr.ecr.us-east-1.amazonaws.com/practice1:25

This prevents every deployment from using an ambiguous `latest` tag.

## Destroy Pipeline

The destroy pipeline is stored in:

Jenkinsfile.destroy

Destroying infrastructure requires the confirmation value:

DESTROY

This is intentionally separate from the normal deployment pipeline.

## Manual Terraform Commands

For development:

cd terraform-infrastructure/environments/dev

terraform init

terraform validate

terraform plan

terraform apply

## Manual Kubernetes Commands

Configure EKS:

aws eks update-kubeconfig \
  --region us-east-1 \
  --name practice1-dev

Check nodes:

kubectl get nodes

Check pods:

kubectl get pods -n practice1

Check service:

kubectl get svc -n practice1

Check deployment:

kubectl get deployment -n practice1

Check endpoints:

kubectl get endpoints -n practice1

## Manual Cleanup

Do not manually delete individual Kubernetes resources unless troubleshooting.

Use the Terraform environment destroy process for infrastructure.

## Security

Never commit:

- AWS access keys
- AWS secret keys
- passwords
- private keys
- .env files
- Terraform state files
- Terraform plans containing sensitive information

Jenkins credentials should be stored in Jenkins Credentials Manager rather than hard-coded in pipeline code.

## Repository Responsibility

### application-code

Application responsibility.

### terraform-infrastructure

Infrastructure responsibility.

### cicd-jenkins-orchestration

Automation and deployment responsibility.

This separation keeps application, infrastructure and CI/CD concerns independent.
