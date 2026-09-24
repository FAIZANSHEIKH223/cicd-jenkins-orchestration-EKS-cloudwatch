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
            name: 'CONFIGURE_CLOUDWATCH',
            defaultValue: true,
            description: 'Configure and verify Amazon CloudWatch Observability for EKS'
        )

        booleanParam(
            name: 'DEPLOY_APPLICATION',
            defaultValue: true,
            description: 'Deploy application to EKS'
        )
    }

    environment {

        AWS_REGION = 'us-east-1'

        APPLICATION_REPO =
            'https://github.com/FAIZANSHEIKH223/application-code.git'

        TERRAFORM_REPO =
            'https://github.com/FAIZANSHEIKH223/terraform-infrastructure-EWS-Cloudwatch.git'

        APPLICATION_DIR = 'application-code'

        TERRAFORM_DIR =
            'terraform-infrastructure-EWS-Cloudwatch'

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

                    echo "=================================================="
                    echo "CLEANING JENKINS WORKSPACE"
                    echo "=================================================="

                    echo "Workspace:"
                    pwd

                    echo "Jenkins node:"
                    hostname

                    echo "Current user:"
                    whoami

                    echo "Workspace cleaned successfully."
                '''
            }
        }


        stage('Checkout Application Code') {

            steps {

                dir("${APPLICATION_DIR}") {

                    checkout([
                        $class: 'GitSCM',

                        branches: [
                            [
                                name: '*/main'
                            ]
                        ],

                        userRemoteConfigs: [
                            [
                                credentialsId:
                                    env.GITHUB_CREDENTIALS_ID,

                                url:
                                    env.APPLICATION_REPO
                            ]
                        ]
                    ])
                }

                sh '''
                    set -e

                    echo "=================================================="
                    echo "APPLICATION REPOSITORY"
                    echo "=================================================="

                    cd "$APPLICATION_DIR"

                    echo "Repository:"
                    git remote -v

                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo "Branch:"
                    git branch --show-current

                    echo "Application repository checked out successfully."
                '''
            }
        }


        stage('Checkout Terraform Code') {

            steps {

                dir("${TERRAFORM_DIR}") {

                    checkout([
                        $class: 'GitSCM',

                        branches: [
                            [
                                name: '*/main'
                            ]
                        ],

                        userRemoteConfigs: [
                            [
                                credentialsId:
                                    env.GITHUB_CREDENTIALS_ID,

                                url:
                                    env.TERRAFORM_REPO
                            ]
                        ]
                    ])
                }

                sh '''
                    set -e

                    echo "=================================================="
                    echo "TERRAFORM REPOSITORY"
                    echo "=================================================="

                    cd "$TERRAFORM_DIR"

                    echo "Repository:"
                    git remote -v

                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo "Branch:"
                    git branch --show-current

                    echo "Terraform repository checked out successfully."
                '''
            }
        }


        stage('Environment Configuration') {

            steps {

                sh '''
                    set -e

                    echo "=================================================="
                    echo "ENVIRONMENT CONFIGURATION"
                    echo "=================================================="

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

                        echo "=================================================="
                        echo "PYTHON DEPENDENCIES"
                        echo "=================================================="

                        "$PYTHON" --version

                        rm -rf "$VENV_DIR"

                        "$PYTHON" -m venv "$VENV_DIR"

                        . "$VENV_DIR/bin/activate"

                        python --version

                        python -m pip install --upgrade pip

                        if [ -f requirements.txt ]; then

                            echo "Installing application requirements..."

                            pip install -r requirements.txt

                        else

                            echo "requirements.txt not found."
                            echo "Continuing with CI tools."

                        fi

                        pip install \
                            pytest \
                            flake8 \
                            pylint

                        echo "Python dependencies installed successfully."
                    '''
                }
            }
        }


        stage('Code Quality and Tests') {

            steps {

                sh '''
                    set -e

                    echo "=================================================="
                    echo "CODE QUALITY AND TESTS"
                    echo "=================================================="

                    ./scripts/quality-check.sh
                '''
            }

            post {

                always {

                    junit(
                        allowEmptyResults: true,
                        testResults:
                            "${APPLICATION_DIR}/reports/pytest-results.xml"
                    )
                }
            }
        }


        stage('Terraform Init and Plan') {

            steps {

                withCredentials([
                    [
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "TERRAFORM INIT AND PLAN"
                        echo "=================================================="

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
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "TERRAFORM APPLY"
                        echo "=================================================="

                        ./scripts/terraform-apply.sh "$ENVIRONMENT"
                    '''
                }
            }
        }


        stage('Configure CloudWatch Observability') {

            when {

                expression {

                    return params.CONFIGURE_CLOUDWATCH
                }
            }

            steps {

                withCredentials([
                    [
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "CLOUDWATCH OBSERVABILITY"
                        echo "=================================================="

                        echo "AWS Region:"
                        echo "$AWS_REGION"

                        echo "Environment:"
                        echo "$ENVIRONMENT"

                        echo "EKS Project:"
                        echo "$EKS_PROJECT_NAME"

                        ./scripts/cloudwatch-configure.sh \
                            "$ENVIRONMENT"
                    '''
                }
            }
        }


        stage('Docker Build') {

            steps {

                sh '''
                    set -e

                    echo "=================================================="
                    echo "DOCKER BUILD"
                    echo "=================================================="

                    ./scripts/docker-build.sh \
                        "$ENVIRONMENT" \
                        "$BUILD_NUMBER"
                '''
            }
        }


        stage('Push Image to ECR') {

            steps {

                withCredentials([
                    [
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "PUSH IMAGE TO ECR"
                        echo "=================================================="

                        ./scripts/ecr-push.sh \
                            "$ENVIRONMENT" \
                            "$BUILD_NUMBER"
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
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "CONFIGURE EKS ACCESS"
                        echo "=================================================="

                        ./scripts/eks-configure.sh \
                            "$ENVIRONMENT"
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
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "DEPLOY APPLICATION TO EKS"
                        echo "=================================================="

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
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "KUBERNETES HEALTH CHECK"
                        echo "=================================================="

                        ./scripts/kubernetes-health-check.sh \
                            "$ENVIRONMENT"
                    '''
                }
            }
        }


        stage('CloudWatch Verification') {

            when {

                expression {

                    return params.CONFIGURE_CLOUDWATCH
                }
            }

            steps {

                withCredentials([
                    [
                        $class:
                            'AmazonWebServicesCredentialsBinding',

                        credentialsId:
                            env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "CLOUDWATCH FINAL VERIFICATION"
                        echo "=================================================="

                        CLUSTER_NAME="${EKS_PROJECT_NAME}-${ENVIRONMENT}"

                        echo "EKS Cluster:"
                        echo "$CLUSTER_NAME"

                        echo ""
                        echo "CloudWatch add-on status:"

                        aws eks describe-addon \
                            --cluster-name "$CLUSTER_NAME" \
                            --addon-name amazon-cloudwatch-observability \
                            --region "$AWS_REGION" \
                            --query 'addon.status' \
                            --output text

                        echo ""
                        echo "CloudWatch Kubernetes resources:"

                        kubectl get pods \
                            -n amazon-cloudwatch \
                            -o wide || true

                        echo ""
                        echo "CloudWatch verification completed."
                    '''
                }
            }
        }
    }


    post {

        success {

            echo """
==================================================
CI/CD PIPELINE COMPLETED SUCCESSFULLY
==================================================
Environment : ${params.ENVIRONMENT}
Build Number: ${env.BUILD_NUMBER}
CloudWatch  : ${params.CONFIGURE_CLOUDWATCH}
==================================================
"""
        }


        failure {

            echo """
==================================================
CI/CD PIPELINE FAILED
==================================================
Environment : ${params.ENVIRONMENT}
Build Number: ${env.BUILD_NUMBER}

Check the Jenkins console output.
==================================================
"""
        }


        always {

            sh '''
                echo "Cleaning temporary Jenkins files..."

                rm -rf \
                    "$APPLICATION_DIR/$VENV_DIR" \
                    "$APPLICATION_DIR/.pytest_cache" \
                    "$APPLICATION_DIR/__pycache__" \
                    "$APPLICATION_DIR/reports" \
                    2>/dev/null || true
            '''
        }
    }
}
