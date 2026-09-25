pipeline {

    agent any

    // ============================================================
    // PIPELINE OPTIONS
    // ============================================================

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

    // ============================================================
    // PARAMETERS
    // ============================================================

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
            description: 'Create or update AWS infrastructure using Terraform'
        )

        booleanParam(
            name: 'CONFIGURE_CLOUDWATCH',
            defaultValue: true,
            description: 'Configure and verify Amazon CloudWatch Observability for EKS'
        )

        booleanParam(
            name: 'DEPLOY_APPLICATION',
            defaultValue: true,
            description: 'Build, push and deploy the application to EKS'
        )
    }

    // ============================================================
    // ENVIRONMENT VARIABLES
    // ============================================================

    environment {

        AWS_REGION = 'us-east-1'

        APPLICATION_REPO =
            'https://github.com/FAIZANSHEIKH223/application-code.git'

        TERRAFORM_REPO =
            'https://github.com/FAIZANSHEIKH223/terraform-infrastructure-EWS-Cloudwatch.git'

        APPLICATION_DIR = 'application-code'

        TERRAFORM_DIR =
            'terraform-infrastructure-EWS-Cloudwatch'

        EKS_PROJECT_NAME = 'practice1'

        CONTAINER_NAME = 'practice1'

        CONTAINER_PORT = '8501'

        K8S_NAMESPACE = 'practice1'

        K8S_DEPLOYMENT = 'practice1-deployment'

        K8S_SERVICE = 'practice1-service'

        GITHUB_CREDENTIALS_ID = 'github-creds'

        AWS_CREDENTIALS_ID = 'aws-creds'

        // This variable will be populated after the EKS
        // LoadBalancer address is discovered.
        APPLICATION_URL = ''
    }

    // ============================================================
    // STAGES
    // ============================================================

    stages {

        // ========================================================
        // 1. CLEAN WORKSPACE
        // ========================================================

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

        // ========================================================
        // 2. CHECKOUT APPLICATION REPOSITORY
        // ========================================================

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
                                credentialsId: env.GITHUB_CREDENTIALS_ID,
                                url: env.APPLICATION_REPO
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

        // ========================================================
        // 3. CHECKOUT TERRAFORM REPOSITORY
        // ========================================================

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
                                credentialsId: env.GITHUB_CREDENTIALS_ID,
                                url: env.TERRAFORM_REPO
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

        // ========================================================
        // 4. ENVIRONMENT CONFIGURATION
        // ========================================================

        stage('Environment Configuration') {

            steps {

                dir("${TERRAFORM_DIR}") {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "ENVIRONMENT CONFIGURATION"
                        echo "=================================================="

                        echo "Environment:"
                        echo "$ENVIRONMENT"

                        echo "AWS Region:"
                        echo "$AWS_REGION"

                        chmod +x scripts/*.sh

                        ./scripts/environment.sh "$ENVIRONMENT"

                        echo "Environment configuration completed successfully."
                    '''
                }
            }
        }

        // ========================================================
        // 5. TERRAFORM INIT AND PLAN
        // ========================================================

        stage('Terraform Init and Plan') {

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "TERRAFORM INIT AND PLAN"
                            echo "=================================================="

                            echo "Environment:"
                            echo "$ENVIRONMENT"

                            echo "AWS Region:"
                            echo "$AWS_REGION"

                            ./scripts/terraform-plan.sh "$ENVIRONMENT"

                            echo "Terraform plan completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 6. TERRAFORM APPLY
        // ========================================================

        stage('Terraform Apply') {

            when {

                expression {
                    return params.RUN_TERRAFORM_APPLY
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "TERRAFORM APPLY"
                            echo "=================================================="

                            echo "Environment:"
                            echo "$ENVIRONMENT"

                            ./scripts/terraform-apply.sh "$ENVIRONMENT"

                            echo "Terraform apply completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 7. CONFIGURE CLOUDWATCH
        // ========================================================

        stage('Configure CloudWatch Observability') {

            when {

                expression {
                    return params.CONFIGURE_CLOUDWATCH
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
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

                            ./scripts/cloudwatch-configure.sh "$ENVIRONMENT"

                            echo "CloudWatch configuration completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 8. DOCKER BUILD
        // ========================================================

        stage('Docker Build') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    sh '''
                        set -e

                        echo "=================================================="
                        echo "DOCKER BUILD"
                        echo "=================================================="

                        echo "Environment:"
                        echo "$ENVIRONMENT"

                        echo "Build Number:"
                        echo "$BUILD_NUMBER"

                        ./scripts/docker-build.sh \
                            "$ENVIRONMENT" \
                            "$BUILD_NUMBER"

                        echo "Docker image built successfully."
                    '''
                }
            }
        }

        // ========================================================
        // 9. PUSH IMAGE TO ECR
        // ========================================================

        stage('Push Image to ECR') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "PUSH IMAGE TO ECR"
                            echo "=================================================="

                            echo "Environment:"
                            echo "$ENVIRONMENT"

                            echo "Build Number:"
                            echo "$BUILD_NUMBER"

                            ./scripts/ecr-push.sh \
                                "$ENVIRONMENT" \
                                "$BUILD_NUMBER"

                            echo "Docker image pushed to ECR successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 10. CONFIGURE EKS ACCESS
        // ========================================================

        stage('Configure EKS Access') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "CONFIGURE EKS ACCESS"
                            echo "=================================================="

                            echo "Cluster:"
                            echo "${EKS_PROJECT_NAME}-${ENVIRONMENT}"

                            ./scripts/eks-configure.sh "$ENVIRONMENT"

                            echo "EKS access configured successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 11. DEPLOY APPLICATION TO EKS
        // ========================================================

        stage('Deploy Application to EKS') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "DEPLOY APPLICATION TO EKS"
                            echo "=================================================="

                            echo "Environment:"
                            echo "$ENVIRONMENT"

                            echo "Build Number:"
                            echo "$BUILD_NUMBER"

                            echo "Namespace:"
                            echo "$K8S_NAMESPACE"

                            echo "Deployment:"
                            echo "$K8S_DEPLOYMENT"

                            echo "Service:"
                            echo "$K8S_SERVICE"

                            ./scripts/kubernetes-deploy.sh \
                                "$ENVIRONMENT" \
                                "$BUILD_NUMBER"

                            echo "Application deployed to EKS successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 12. KUBERNETES HEALTH CHECK
        // ========================================================

        stage('Kubernetes Health Check') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=================================================="
                            echo "KUBERNETES HEALTH CHECK"
                            echo "=================================================="

                            echo "Environment:"
                            echo "$ENVIRONMENT"

                            echo "Namespace:"
                            echo "$K8S_NAMESPACE"

                            ./scripts/kubernetes-health-check.sh \
                                "$ENVIRONMENT"

                            echo "Kubernetes health check completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 13. GET APPLICATION UI URL
        // ========================================================

        stage('Get Application UI URL') {

            when {

                expression {
                    return params.DEPLOY_APPLICATION
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        script {

                            sh '''
                                set -e

                                echo "=================================================="
                                echo "GET APPLICATION UI URL"
                                echo "=================================================="

                                echo "Waiting for Kubernetes Service"
                                echo "to receive an external LoadBalancer address..."

                                for i in $(seq 1 30); do

                                    EXTERNAL_ADDRESS=$(kubectl get service "$K8S_SERVICE" \
                                        -n "$K8S_NAMESPACE" \
                                        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
                                        2>/dev/null || true)

                                    if [ -z "$EXTERNAL_ADDRESS" ]; then
                                        EXTERNAL_ADDRESS=$(kubectl get service "$K8S_SERVICE" \
                                            -n "$K8S_NAMESPACE" \
                                            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' \
                                            2>/dev/null || true)
                                    fi

                                    if [ -n "$EXTERNAL_ADDRESS" ]; then
                                        echo ""
                                        echo "=================================================="
                                        echo "APPLICATION LOAD BALANCER FOUND"
                                        echo "=================================================="
                                        echo "External Address: $EXTERNAL_ADDRESS"
                                        echo "=================================================="
                                        exit 0
                                    fi

                                    echo "Attempt $i/30:"
                                    echo "LoadBalancer address is not available yet."

                                    sleep 10
                                done

                                echo ""
                                echo "ERROR: Application LoadBalancer address was not"
                                echo "available after waiting for 5 minutes."
                                echo ""
                                echo "Current Kubernetes Service:"
                                kubectl get service "$K8S_SERVICE" \
                                    -n "$K8S_NAMESPACE" \
                                    -o wide

                                exit 1
                            '''

                            def applicationAddress = sh(
                                script: '''
                                    set -e

                                    ADDRESS=$(kubectl get service "$K8S_SERVICE" \
                                        -n "$K8S_NAMESPACE" \
                                        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
                                        2>/dev/null || true)

                                    if [ -z "$ADDRESS" ]; then
                                        ADDRESS=$(kubectl get service "$K8S_SERVICE" \
                                            -n "$K8S_NAMESPACE" \
                                            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' \
                                            2>/dev/null || true)
                                    fi

                                    echo "$ADDRESS"
                                ''',
                                returnStdout: true
                            ).trim()

                            if (!applicationAddress) {
                                error(
                                    "Unable to determine the external LoadBalancer address."
                                )
                            }

                            env.APPLICATION_URL =
                                "http://${applicationAddress}"

                            echo ""
                            echo "=================================================="
                            echo "APPLICATION UI"
                            echo "=================================================="
                            echo "Application URL:"
                            echo "${env.APPLICATION_URL}"
                            echo "=================================================="
                            echo ""
                        }
                    }
                }
            }
        }

        // ========================================================
        // 14. CLOUDWATCH FINAL VERIFICATION
        // ========================================================

        stage('CloudWatch Verification') {

            when {

                expression {
                    return params.CONFIGURE_CLOUDWATCH
                }
            }

            steps {

                dir("${TERRAFORM_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
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
                                -o wide

                            echo ""
                            echo "CloudWatch verification completed successfully."
                        '''
                    }
                }
            }
        }
    }

    // ============================================================
    // POST ACTIONS
    // ============================================================

    post {

        success {

            echo """
==================================================
CI/CD PIPELINE COMPLETED SUCCESSFULLY
==================================================
Environment  : ${params.ENVIRONMENT}
Build Number : ${env.BUILD_NUMBER}
Terraform    : ${params.RUN_TERRAFORM_APPLY}
CloudWatch   : ${params.CONFIGURE_CLOUDWATCH}
Application  : ${params.DEPLOY_APPLICATION}
Application UI:
${env.APPLICATION_URL ?: 'Not generated because application deployment was disabled'}
==================================================
"""
        }

        failure {

            echo """
==================================================
CI/CD PIPELINE FAILED
==================================================
Environment  : ${params.ENVIRONMENT}
Build Number : ${env.BUILD_NUMBER}

Check the Jenkins console output for the failed stage.
==================================================
"""
        }

        always {

            sh '''
                echo "=================================================="
                echo "JENKINS WORKSPACE CLEANUP"
                echo "=================================================="

                rm -rf \
                    "$APPLICATION_DIR/.pytest_cache" \
                    "$APPLICATION_DIR/__pycache__" \
                    "$APPLICATION_DIR/reports" \
                    2>/dev/null || true

                echo "Temporary Jenkins files cleaned."
            '''
        }
    }
}
