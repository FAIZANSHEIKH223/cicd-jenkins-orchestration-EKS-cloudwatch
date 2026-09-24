#!/usr/bin/env groovy

pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: [
                'dev',
                'qa',
                'stage',
                'prod'
            ],
            description: 'Select the deployment environment'
        )

        booleanParam(
            name: 'RUN_TERRAFORM_APPLY',
            defaultValue: true,
            description: 'Create/update AWS infrastructure using Terraform'
        )

        booleanParam(
            name: 'DEPLOY_APPLICATION',
            defaultValue: true,
            description: 'Deploy application to EKS'
        )
    }

    environment {
        AWS_REGION = 'us-east-1'

        APPLICATION_REPO = 'https://github.com/FAIZANSHEIKH223/application-code.git'
        TERRAFORM_REPO = 'https://github.com/FAIZANSHEIKH223/terraform-infrastructure.git'

        APPLICATION_DIR = 'application-code'
        TERRAFORM_DIR = 'terraform-infrastructure'

        PYTHON = 'python3.12'
        VENV_DIR = 'venv'

        EKS_PROJECT_NAME = 'practice1'

        CONTAINER_NAME = 'practice1'
        CONTAINER_PORT = '8501'

        K8S_NAMESPACE = 'practice1'
        K8S_DEPLOYMENT = 'practice1-deployment'
        K8S_SERVICE = 'practice1-service'

        GITHUB_CREDENTIALS_ID = 'github-creds'
        AWS_CREDENTIALS_ID = 'aws-creds'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()

                sh '''
                    set -e

                    echo "Workspace cleaned successfully."

                    echo "Jenkins node:"
                    hostname

                    echo "Current user:"
                    whoami
                '''
            }
        }

        stage('Checkout Application Code') {
            steps {
                dir("${APPLICATION_DIR}") {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            credentialsId: env.GITHUB_CREDENTIALS_ID,
                            url: env.APPLICATION_REPO
                        ]]
                    ])
                }

                sh '''
                    set -e

                    echo "Application repository checked out."

                    cd "$APPLICATION_DIR"

                    echo "Application commit:"
                    git rev-parse --short HEAD

                    echo "Application branch:"
                    git branch --show-current
                '''
            }
        }

        stage('Checkout Terraform Code') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            credentialsId: env.GITHUB_CREDENTIALS_ID,
                            url: env.TERRAFORM_REPO
                        ]]
                    ])
                }

                sh '''
                    set -e

                    echo "Terraform repository checked out."

                    cd "$TERRAFORM_DIR"

                    echo "Terraform commit:"
                    git rev-parse --short HEAD
                '''
            }
        }

        stage('Environment Configuration') {
            steps {
                sh '''
                    set -e

                    chmod +x scripts/*.sh

                    ./scripts/environment.sh "$ENVIRONMENT"
                '''
            }
        }

        stage('Install Python Dependencies') {
            steps {
                dir("${APPLICATION_DIR}") {
                    sh '''
                        set -e

                        "$PYTHON" --version

                        rm -rf "$VENV_DIR"

                        "$PYTHON" -m venv "$VENV_DIR"

                        . "$VENV_DIR/bin/activate"

                        python --version
                        pip --version

                        python -m pip install --upgrade pip

                        if [ -f requirements.txt ]; then
                            pip install -r requirements.txt
                        fi

                        pip install pytest flake8 pylint

                        echo "Python dependencies installed successfully."
                    '''
                }
            }
        }

        stage('Code Quality and Tests') {
            steps {
                sh '''
                    set -e

                    ./scripts/quality-check.sh
                '''
            }

            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: "${APPLICATION_DIR}/reports/pytest-results.xml"
                }
            }
        }

        stage('Terraform Init and Plan') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/terraform-plan.sh "$ENVIRONMENT"
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    return params.RUN_TERRAFORM_APPLY
                }
            }

            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/terraform-apply.sh "$ENVIRONMENT"
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    ./scripts/docker-build.sh "$ENVIRONMENT" "$BUILD_NUMBER"
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/ecr-push.sh "$ENVIRONMENT" "$BUILD_NUMBER"
                    '''
                }
            }
        }

        stage('Configure EKS Access') {
            when {
                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/eks-configure.sh "$ENVIRONMENT"
                    '''
                }
            }
        }

        stage('Deploy Application to EKS') {
            when {
                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/kubernetes-deploy.sh \
                            "$ENVIRONMENT" \
                            "$BUILD_NUMBER"
                    '''
                }
            }
        }

        stage('Kubernetes Health Check') {
            when {
                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {
                    sh '''
                        set -e

                        ./scripts/kubernetes-health-check.sh "$ENVIRONMENT"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "=========================================="
            echo "CI/CD PIPELINE COMPLETED SUCCESSFULLY"
            echo "Environment: ${params.ENVIRONMENT}"
            echo "Build Number: ${env.BUILD_NUMBER}"
            echo "=========================================="
        }

        failure {
            echo "=========================================="
            echo "CI/CD PIPELINE FAILED"
            echo "Environment: ${params.ENVIRONMENT}"
            echo "Build Number: ${env.BUILD_NUMBER}"
            echo "Check the Jenkins console output."
            echo "=========================================="
        }

        always {
            sh '''
                echo "Cleaning temporary Jenkins files..."

                rm -rf \
                    "$APPLICATION_DIR/$VENV_DIR" \
                    "$APPLICATION_DIR/.pytest_cache" \
                    "$APPLICATION_DIR/__pycache__" \
                    "$APPLICATION_DIR/reports" 2>/dev/null || true
            '''
        }
    }
}
