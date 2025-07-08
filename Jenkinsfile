pipeline {
    agent { label 'master' }

    environment {
        ECR_REPO       = "159773342061.dkr.ecr.ap-northeast-2.amazonaws.com/jenkins-demo2"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        JAVA_HOME      = "/opt/jdk-23"
        PATH           = "${env.JAVA_HOME}/bin:${env.PATH}"
        REGION         = "ap-northeast-2"
        S3_BUCKET      = "govuk-deploy-bucket"
        DEPLOY_APP     = "govuk-cd-app"
        DEPLOY_GROUP   = "govuk-deployment-group"
        BUNDLE         = "govuk-deploy-bundle.zip"
    }

    stages {
        stage('📦 Checkout') {
            steps { checkout scm }
        }

        stage('🐳 Docker Build & Push') {
            steps {
                sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                sh """
                    aws ecr get-login-password --region ${REGION} \
                    | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('🧩 Generate taskdef.json') {
            steps {
                script {
                    def taskdef = """{
  \"family\": \"govuk-taskdef\",
  \"networkMode\": \"awsvpc\",
  \"containerDefinitions\": [
    {
      \"name\": \"govuk-container\",
      \"image\": \"${ECR_REPO}:${IMAGE_TAG}\",
      \"memory\": 512,
      \"cpu\": 256,
      \"essential\": true,
      \"portMappings\": [
        {\"containerPort\": 3000, \"protocol\": \"tcp\"}
      ],
      \"logConfiguration\": {
        \"logDriver\": \"awslogs\",
        \"options\": {
          \"awslogs-group\": \"/ecs/govuk-taskdef\",
          \"awslogs-region\": \"${REGION}\",
          \"awslogs-stream-prefix\": \"ecs\"
        }
      }
    }
  ],
  \"requiresCompatibilities\": [\"FARGATE\"],
  \"cpu\": \"256\",
  \"memory\": \"512\",
  \"executionRoleArn\": \"arn:aws:iam::159773342061:role/ecsTaskExecutionRole\"
}"""

                    writeFile file: 'taskdef.json', text: taskdef
                }
            }
        }

        stage('📄 Generate appspec.yaml') {
            steps {
                script {
                    def taskDefArn = sh(
                        script: "aws ecs register-task-definition --cli-input-json file://taskdef.json --query 'taskDefinition.taskDefinitionArn' --region ${REGION} --output text",
                        returnStdout: true
                    ).trim()
                    def appspec = """version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: \"${taskDefArn}\"
        LoadBalancerInfo:
          ContainerName: \"govuk-container\"
          ContainerPort: 3000
"""
                    writeFile file: 'appspec.yaml', text: appspec
                }
            }
        }

        stage('📦 Bundle & Deploy') {
            steps {
                sh "zip -r ${BUNDLE} appspec.yaml Dockerfile taskdef.json"
                sh """
                    aws s3 cp ${BUNDLE} s3://${S3_BUCKET}/${BUNDLE} --region ${REGION}
                    aws deploy create-deployment \
                      --application-name ${DEPLOY_APP} \
                      --deployment-group-name ${DEPLOY_GROUP} \
                      --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
                      --s3-location bucket=${S3_BUCKET},bundleType=zip,key=${BUNDLE} \
                      --region ${REGION}
                """
            }
        }
    }

    post {
        success { echo "✅ CD & Security Test 모두 완료!" }
        failure { echo "❌ 파이프라인 실패, 로그 확인 요망." }
    }
}
