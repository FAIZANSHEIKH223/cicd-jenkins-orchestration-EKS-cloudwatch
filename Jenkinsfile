pipeline {

    agent any

    // ============================================================
    // PIPELINE OPTIONS
    // ============================================================

    options {

        timestamps()

        ansiColor('xterm')

        disableConcurrentBuilds()

        skipDefaultCheckout(true)

        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )

        timeout(
            time: 60,
            unit: 'MINUTES'
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
            description: 'AWS/Kubernetes environment to deploy'
        )
    }

    // ============================================================
    // GLOBAL ENVIRONMENT
    // ============================================================

    environment {

        // --------------------------------------------------------
        // AWS
        // --------------------------------------------------------

        AWS_REGION = 'us-east-1'

        AWS_DEFAULT_REGION = 'us-east-1'

        // --------------------------------------------------------
        // GITHUB REPOSITORIES
        // --------------------------------------------------------

        APPLICATION_REPO =
            'https://github.com/FAIZANSHEIKH223/application-code.git'

        TERRAFORM_REPO =
            'https://github.com/FAIZANSHEIKH223/terraform-infrastructure-EWS-Cloudwatch.git'

        CICD_REPO =
            'https://github.com/FAIZANSHEIKH223/cicd-jenkins-orchestration-EKS-cloudwatch.git'

        // --------------------------------------------------------
        // JENKINS WORKSPACE DIRECTORIES
        // --------------------------------------------------------

        APPLICATION_DIR =
            'application-code'

        TERRAFORM_DIR =
            'terraform-infrastructure-EWS-Cloudwatch'

        CICD_DIR =
            'cicd-jenkins-orchestration-EKS-cloudwatch'

        // --------------------------------------------------------
        // APPLICATION
        // --------------------------------------------------------

        EKS_PROJECT_NAME =
            'practice1'

        CONTAINER_NAME =
            'practice1'

        CONTAINER_PORT =
            '8501'

        // --------------------------------------------------------
        // KUBERNETES
        // --------------------------------------------------------

        K8S_NAMESPACE =
            'practice1'

        K8S_DEPLOYMENT =
            'practice1-deployment'

        K8S_SERVICE =
            'practice1-service'

        // --------------------------------------------------------
        // JENKINS CREDENTIALS
        // --------------------------------------------------------

        GITHUB_CREDENTIALS_ID =
            'github-creds'

        AWS_CREDENTIALS_ID =
            'aws-creds'

        // --------------------------------------------------------
        // TERRAFORM REMOTE STATE
        // --------------------------------------------------------

        TERRAFORM_STATE_BUCKET =
            'terraform-state-faizan-001'

        TERRAFORM_LOCK_TABLE =
            'terraform-locks'

        // --------------------------------------------------------
        // APPLICATION URL
        // --------------------------------------------------------

        APPLICATION_URL =
            ''
    }

    // ============================================================
    // STAGES
    // ============================================================

    stages {

        // ========================================================
        // 01. CLEAN WORKSPACE
        // ========================================================

        stage('01 - Clean Workspace') {

            steps {

                deleteDir()

                sh '''
                    set -e

                    echo "=============================================================="
                    echo "                    CLEAN WORKSPACE"
                    echo "=============================================================="

                    echo "Workspace:"
                    pwd

                    echo ""
                    echo "Jenkins node:"
                    hostname

                    echo ""
                    echo "Jenkins user:"
                    whoami

                    echo ""
                    echo "Workspace cleaned successfully."
                '''
            }
        }

        // ========================================================
        // 02. CHECK TOOLS
        // ========================================================

        stage('02 - Verify Required Tools') {

            steps {

                sh '''
                    set -e

                    echo "=============================================================="
                    echo "                    VERIFY TOOLS"
                    echo "=============================================================="

                    echo ""
                    echo "Git:"
                    git --version

                    echo ""
                    echo "Terraform:"
                    terraform version

                    echo ""
                    echo "AWS CLI:"
                    aws --version

                    echo ""
                    echo "Docker:"
                    docker --version

                    echo ""
                    echo "kubectl:"
                    kubectl version --client

                    echo ""
                    echo "Required tools are available."
                '''
            }
        }

        // ========================================================
        // 03. VERIFY AWS CREDENTIALS
        // ========================================================

        stage('03 - Verify AWS Credentials') {

            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=============================================================="
                        echo "                    AWS CREDENTIAL CHECK"
                        echo "=============================================================="

                        aws sts get-caller-identity

                        echo ""
                        echo "AWS Region:"
                        echo "$AWS_REGION"

                        echo ""
                        echo "AWS credentials are working."
                    '''
                }
            }
        }

        // ========================================================
        // 04. CHECKOUT APPLICATION
        // ========================================================

        stage('04 - Checkout Application Repository') {

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

                    echo "=============================================================="
                    echo "                 APPLICATION REPOSITORY"
                    echo "=============================================================="

                    cd "$APPLICATION_DIR"

                    echo "Repository:"
                    git remote get-url origin

                    echo ""
                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo ""
                    echo "Branch:"
                    git branch --show-current

                    echo ""
                    echo "Application files:"
                    find . -maxdepth 2 -type f | sort

                    echo ""
                    echo "Application repository checked out successfully."
                '''
            }
        }

        // ========================================================
        // 05. CHECKOUT TERRAFORM
        // ========================================================

        stage('05 - Checkout Terraform Repository') {

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

                    echo "=============================================================="
                    echo "                 TERRAFORM REPOSITORY"
                    echo "=============================================================="

                    cd "$TERRAFORM_DIR"

                    echo "Repository:"
                    git remote get-url origin

                    echo ""
                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo ""
                    echo "Branch:"
                    git branch --show-current

                    echo ""
                    echo "Terraform environments:"
                    find environments -maxdepth 2 -type f | sort

                    echo ""
                    echo "Terraform modules:"
                    find modules -maxdepth 2 -type f | sort

                    echo ""
                    echo "Terraform repository checked out successfully."
                '''
            }
        }

        // ========================================================
        // 06. CHECKOUT CI/CD
        // ========================================================

        stage('06 - Checkout CI/CD Repository') {

            steps {

                dir("${CICD_DIR}") {

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
                                    env.CICD_REPO
                            ]
                        ]
                    ])
                }

                sh '''
                    set -e

                    echo "=============================================================="
                    echo "                 CI/CD REPOSITORY"
                    echo "=============================================================="

                    cd "$CICD_DIR"

                    echo "Repository:"
                    git remote get-url origin

                    echo ""
                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo ""
                    echo "Branch:"
                    git branch --show-current

                    echo ""
                    echo "CI/CD scripts:"
                    find scripts -maxdepth 1 -type f -name "*.sh" | sort

                    echo ""
                    echo "Kubernetes manifests:"
                    find k8s -maxdepth 1 -type f | sort

                    echo ""
                    echo "CI/CD repository checked out successfully."
                '''
            }
        }

        // ========================================================
        // 07. CONFIGURE ENVIRONMENT
        // ========================================================

        stage('07 - Environment Configuration') {

            steps {

                dir("${CICD_DIR}") {

                    sh '''
                        set -e

                        echo "=============================================================="
                        echo "                 ENVIRONMENT CONFIGURATION"
                        echo "=============================================================="

                        echo "Environment:"
                        echo "$ENVIRONMENT"

                        echo ""
                        echo "AWS Region:"
                        echo "$AWS_REGION"

                        echo ""
                        echo "Making CI/CD scripts executable..."

                        chmod +x scripts/*.sh

                        echo ""
                        echo "Running environment configuration..."

                        ./scripts/environment.sh \
                            "$ENVIRONMENT"

                        echo ""
                        echo "Environment configuration completed."
                    '''
                }
            }
        }

        // ========================================================
        // 08. TERRAFORM BACKEND
        // ========================================================

        stage('08 - Ensure Terraform Backend') {

            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=============================================================="
                        echo "              TERRAFORM REMOTE BACKEND"
                        echo "=============================================================="

                        echo "S3 Bucket:"
                        echo "$TERRAFORM_STATE_BUCKET"

                        echo ""
                        echo "DynamoDB Lock Table:"
                        echo "$TERRAFORM_LOCK_TABLE"

                        echo ""
                        echo "Checking S3 backend bucket..."

                        if aws s3api head-bucket \
                            --bucket "$TERRAFORM_STATE_BUCKET" \
                            --region "$AWS_REGION" \
                            >/dev/null 2>&1
                        then

                            echo "S3 backend bucket already exists."

                        else

                            echo "S3 backend bucket does not exist."
                            echo "Creating bucket..."

                            aws s3api create-bucket \
                                --bucket "$TERRAFORM_STATE_BUCKET" \
                                --region "$AWS_REGION"

                            aws s3api wait bucket-exists \
                                --bucket "$TERRAFORM_STATE_BUCKET" \
                                --region "$AWS_REGION"

                            echo "S3 backend bucket created."

                        fi

                        echo ""
                        echo "Enabling S3 versioning..."

                        aws s3api put-bucket-versioning \
                            --bucket "$TERRAFORM_STATE_BUCKET" \
                            --region "$AWS_REGION" \
                            --versioning-configuration Status=Enabled

                        echo ""
                        echo "Enabling S3 encryption..."

                        aws s3api put-bucket-encryption \
                            --bucket "$TERRAFORM_STATE_BUCKET" \
                            --region "$AWS_REGION" \
                            --server-side-encryption-configuration '{
                                "Rules": [
                                    {
                                        "ApplyServerSideEncryptionByDefault": {
                                            "SSEAlgorithm": "AES256"
                                        }
                                    }
                                ]
                            }'

                        echo ""
                        echo "Blocking public access..."

                        aws s3api put-public-access-block \
                            --bucket "$TERRAFORM_STATE_BUCKET" \
                            --region "$AWS_REGION" \
                            --public-access-block-configuration \
                            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

                        echo ""
                        echo "Checking DynamoDB lock table..."

                        if aws dynamodb describe-table \
                            --table-name "$TERRAFORM_LOCK_TABLE" \
                            --region "$AWS_REGION" \
                            >/dev/null 2>&1
                        then

                            echo "DynamoDB lock table already exists."

                        else

                            echo "DynamoDB lock table does not exist."
                            echo "Creating table..."

                            aws dynamodb create-table \
                                --table-name "$TERRAFORM_LOCK_TABLE" \
                                --attribute-definitions \
                                    AttributeName=LockID,AttributeType=S \
                                --key-schema \
                                    AttributeName=LockID,KeyType=HASH \
                                --billing-mode PAY_PER_REQUEST \
                                --region "$AWS_REGION"

                            aws dynamodb wait table-exists \
                                --table-name "$TERRAFORM_LOCK_TABLE" \
                                --region "$AWS_REGION"

                            echo "DynamoDB lock table created."
                        fi

                        echo ""
                        echo "Terraform backend resources are ready."
                    '''
                }
            }
        }

        // ========================================================
        // 09. CONFIGURE TERRAFORM BACKEND
        // ========================================================

        stage('09 - Configure Terraform Backend') {

            steps {

                sh '''
                    set -e

                    echo "=============================================================="
                    echo "             CONFIGURE TERRAFORM STATE BACKEND"
                    echo "=============================================================="

                    TERRAFORM_ENV_DIR="$WORKSPACE/$TERRAFORM_DIR/environments/$ENVIRONMENT"

                    if [ ! -d "$TERRAFORM_ENV_DIR" ]; then
                        echo "ERROR: Terraform environment directory not found:"
                        echo "$TERRAFORM_ENV_DIR"
                        exit 1
                    fi

                    echo "Terraform environment:"
                    echo "$TERRAFORM_ENV_DIR"

                    cat > "$TERRAFORM_ENV_DIR/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket         = "$TERRAFORM_STATE_BUCKET"
    key            = "practice1/$ENVIRONMENT/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$TERRAFORM_LOCK_TABLE"
    encrypt        = true
  }
}
EOF

                    echo ""
                    echo "Generated Terraform backend configuration:"
                    cat "$TERRAFORM_ENV_DIR/backend.tf"

                    echo ""
                    echo "Terraform backend configuration completed."
                '''
            }
        }

        // ========================================================
        // 10. TERRAFORM PLAN
        // ========================================================

        stage('10 - Terraform Init and Plan') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                 TERRAFORM INIT AND PLAN"
                            echo "=============================================================="

                            ./scripts/terraform-plan.sh \
                                "$ENVIRONMENT"

                            echo ""
                            echo "Terraform plan completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 11. TERRAFORM APPLY
        // ========================================================

        stage('11 - Terraform Apply') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                    TERRAFORM APPLY"
                            echo "=============================================================="

                            ./scripts/terraform-apply.sh \
                                "$ENVIRONMENT"

                            echo ""
                            echo "Terraform infrastructure applied successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 12. CONFIGURE EKS ACCESS
        // ========================================================

        stage('12 - Configure EKS Access') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                  CONFIGURE EKS ACCESS"
                            echo "=============================================================="

                            ./scripts/eks-configure.sh \
                                "$ENVIRONMENT"

                            echo ""
                            echo "EKS access configured."

                            echo ""
                            echo "EKS nodes:"
                            kubectl get nodes -o wide
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 13. CLOUDWATCH
        // ========================================================

        stage('13 - Configure CloudWatch Observability') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "             CLOUDWATCH OBSERVABILITY"
                            echo "=============================================================="

                            ./scripts/cloudwatch-configure.sh \
                                "$ENVIRONMENT"

                            echo ""
                            echo "CloudWatch Observability configured successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 14. DOCKER BUILD
        // ========================================================

        stage('14 - Docker Build') {

            steps {

                dir("${CICD_DIR}") {

                    sh '''
                        set -e

                        echo "=============================================================="
                        echo "                       DOCKER BUILD"
                        echo "=============================================================="

                        ./scripts/docker-build.sh \
                            "$ENVIRONMENT" \
                            "$BUILD_NUMBER"

                        echo ""
                        echo "Docker image built successfully."
                    '''
                }
            }
        }

        // ========================================================
        // 15. ECR PUSH
        // ========================================================

        stage('15 - Push Image to ECR') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                    PUSH IMAGE TO ECR"
                            echo "=============================================================="

                            ./scripts/ecr-push.sh \
                                "$ENVIRONMENT" \
                                "$BUILD_NUMBER"

                            echo ""
                            echo "Docker image pushed to ECR successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 16. DEPLOY TO EKS
        // ========================================================

        stage('16 - Deploy Application to EKS') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                 DEPLOY APPLICATION TO EKS"
                            echo "=============================================================="

                            ./scripts/kubernetes-deploy.sh \
                                "$ENVIRONMENT" \
                                "$BUILD_NUMBER"

                            echo ""
                            echo "Application deployment completed."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 17. KUBERNETES HEALTH CHECK
        // ========================================================

        stage('17 - Kubernetes Health Check') {

            steps {

                dir("${CICD_DIR}") {

                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: env.AWS_CREDENTIALS_ID
                        ]
                    ]) {

                        sh '''
                            set -e

                            echo "=============================================================="
                            echo "                 KUBERNETES HEALTH CHECK"
                            echo "=============================================================="

                            ./scripts/kubernetes-health-check.sh \
                                "$ENVIRONMENT"

                            echo ""
                            echo "Kubernetes health check completed successfully."
                        '''
                    }
                }
            }
        }

        // ========================================================
        // 18. FINAL APPLICATION URL
        // ========================================================

        stage('18 - Get Application UI URL') {

            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    script {

                        def applicationAddress = sh(
                            script: '''
                                set -e

                                echo "Waiting for LoadBalancer address..." >&2

                                for i in $(seq 1 30); do

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

                                    if [ -n "$ADDRESS" ]; then
                                        echo "$ADDRESS"
                                        exit 0
                                    fi

                                    echo "Attempt $i/30 - LoadBalancer address not ready." >&2

                                    sleep 10
                                done

                                echo "ERROR: LoadBalancer address was not assigned within 5 minutes." >&2

                                kubectl get service "$K8S_SERVICE" \
                                    -n "$K8S_NAMESPACE" \
                                    -o wide >&2

                                exit 1
                            ''',
                            returnStdout: true
                        ).trim()

                        if (!applicationAddress) {

                            error(
                                "Application LoadBalancer address could not be determined."
                            )
                        }

                        env.APPLICATION_URL =
                            "http://${applicationAddress}"

                        echo ""
                        echo "=============================================================="
                        echo "                 APPLICATION DEPLOYED"
                        echo "=============================================================="
                        echo ""
                        echo "Environment : ${params.ENVIRONMENT}"
                        echo "Build       : ${env.BUILD_NUMBER}"
                        echo "Cluster     : ${env.EKS_PROJECT_NAME}-${params.ENVIRONMENT}"
                        echo "Namespace   : ${env.K8S_NAMESPACE}"
                        echo "Service     : ${env.K8S_SERVICE}"
                        echo ""
                        echo "APPLICATION UI URL:"
                        echo "${env.APPLICATION_URL}"
                        echo ""
                        echo "=============================================================="
                    }
                }
            }
        }

        // ========================================================
        // 19. CLOUDWATCH FINAL VERIFICATION
        // ========================================================

        stage('19 - Final CloudWatch Verification') {

            steps {

                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: env.AWS_CREDENTIALS_ID
                    ]
                ]) {

                    sh '''
                        set -e

                        echo "=============================================================="
                        echo "             FINAL CLOUDWATCH VERIFICATION"
                        echo "=============================================================="

                        CLUSTER_NAME="${EKS_PROJECT_NAME}-${ENVIRONMENT}"

                        echo "Cluster:"
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
                        echo "CloudWatch namespace:"

                        kubectl get namespace \
                            amazon-cloudwatch \
                            --ignore-not-found=true

                        echo ""
                        echo "CloudWatch pods:"

                        kubectl get pods \
                            -n amazon-cloudwatch \
                            -o wide

                        echo ""
                        echo "CloudWatch verification completed."
                    '''
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
==============================================================
             CI/CD PIPELINE COMPLETED SUCCESSFULLY
==============================================================

Environment : ${params.ENVIRONMENT}
Build       : ${env.BUILD_NUMBER}
Cluster     : ${env.EKS_PROJECT_NAME}-${params.ENVIRONMENT}
Namespace   : ${env.K8S_NAMESPACE}
Service     : ${env.K8S_SERVICE}

APPLICATION UI:
${env.APPLICATION_URL}

==============================================================
No manual deployment step is required.
==============================================================
"""
        }

        failure {

            echo """
==============================================================
                 CI/CD PIPELINE FAILED
==============================================================

Environment : ${params.ENVIRONMENT}
Build       : ${env.BUILD_NUMBER}

Review the failed stage in the Jenkins console output.

==============================================================
"""
        }

        always {

            sh '''
                echo "=============================================================="
                echo "                    WORKSPACE CLEANUP"
                echo "=============================================================="

                rm -rf \
                    "$APPLICATION_DIR/__pycache__" \
                    "$APPLICATION_DIR/.pytest_cache" \
                    2>/dev/null || true

                echo "Temporary application files cleaned."
            '''
        }
    }
}
